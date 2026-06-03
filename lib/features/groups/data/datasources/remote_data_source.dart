import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takturns_flutter_app/core/di/injection_container.dart';
import '../../../../core/constants/abis.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/group.dart';
import '../models/cycle_progress_model.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';

abstract class GroupRemoteDataSource {
  Future<String> createGroup({
    required int minGrade,
    required BigInt contributionAmount,
    required BigInt cycleDuration,
    required int maxMembers,
    required String token,
  });
  Future<BigInt> getCollateralAmount({required BigInt contribution, required int minGrade});
  Future<void> approveUsdc({required String spender, required BigInt amount});
  Future<void> joinGroup({required String groupAddress});
  Future<void> startGroup({required String groupAddress});
  Future<void> contribute({required String groupAddress});
  Future<void> flagDefaulter({required String groupAddress, required String memberAddress});
  Future<void> castVote({required String groupAddress, required int vote});
  Future<void> resolveVote({required String groupAddress});
  Future<GroupModel> getGroupDetails(String groupAddress);
  Future<CycleProgressModel> getCycleProgress(String groupAddress);
  Future<List<MemberModel>> getMembers(String groupAddress);
  Future<List<GroupModel>> getUserGroups(String walletAddress);
  Future<List<GroupModel>> getCreatedGroups(String walletAddress);
  Future<bool> hasContributed({required String groupAddress, required String memberAddress});
  Future<String> getCurrentRecipient(String groupAddress);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final Web3Client _client;
  
  ReownAppKitModal get _appKit => sl<ReownAppKitModal>();

  GroupRemoteDataSourceImpl(this._client);

  // ─── Helpers ───────────────────────────────────────────────────────────────

  DeployedContract _factoryContract() => DeployedContract(
    ContractAbi.fromJson(ContractAbis.factory, 'TakturnsFactory'),
    EthereumAddress.fromHex(AppConstants.factoryAddress),
  );

  DeployedContract _groupContract(String address) => DeployedContract(
    ContractAbi.fromJson(ContractAbis.group, 'TakturnsGroup'),
    EthereumAddress.fromHex(address),
  );

  DeployedContract _erc20Contract(String address) => DeployedContract(
    ContractAbi.fromJson(ContractAbis.erc20, 'ERC20'),
    EthereumAddress.fromHex(address),
  );

  Future<String> _sendTx({
    required DeployedContract contract,
    required String functionName,
    required List<dynamic> params,
    BigInt? gasLimit,
  }) async {
    if (_appKit.session == null) {
      throw Exception('Wallet not connected');
    }
    
    final fn = contract.function(functionName);
    final data = fn.encodeCall(params);
    
    // We get the raw namespace address from ReownAppKit e.g. "eip155:421614:0x123..."
    final String fullAddress = _appKit.session!.getAddress('eip155')!;
    final String senderAddress = fullAddress.contains(':') ? fullAddress.split(':').last : fullAddress;

    // Ensure the wallet is on Arbitrum Sepolia before sending
    const targetChainId = 'eip155:${AppConstants.chainId}';
    if (_appKit.selectedChain?.chainId != '${AppConstants.chainId}') {
      final arbitrumSepolia = ReownAppKitModalNetworks.getNetworkInfo(
        'eip155',
        '${AppConstants.chainId}',
      );
      if (arbitrumSepolia != null) {
        await _appKit.selectChain(arbitrumSepolia);
      }
    }

    final result = await _appKit.request(
      topic: _appKit.session!.topic,
      chainId: targetChainId,
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [
          {
            'from': senderAddress,
            'to': contract.address.hex,
            'data': '0x${bytesToHex(data)}',
            // Reown will let the wallet estimate gas, or we could pass it if needed
          }
        ],
      ),
    );
    
    if (result == null || result is! String) {
      throw Exception('Failed to get transaction hash from wallet');
    }
    return result;
  }

  // ─── Implementation ────────────────────────────────────────────────────────

  @override
  Future<String> createGroup({
    required int minGrade,
    required BigInt contributionAmount,
    required BigInt cycleDuration,
    required int maxMembers,
    required String token,
  }) async {
    final factory = _factoryContract();
    final txHash = await _sendTx(
      contract: factory,
      functionName: 'createGroup',
      params: [
        BigInt.from(minGrade),
        contributionAmount,
        cycleDuration,
        BigInt.from(maxMembers),
        EthereumAddress.fromHex(token),
      ],
      gasLimit: BigInt.from(800000),
    );

    TransactionReceipt? receipt;
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      receipt = await _client.getTransactionReceipt(txHash);
      if (receipt != null) break;
    }

    if (receipt == null) throw Exception('Transaction not mined');

    final event = factory.event('GroupCreated');
    for (final log in receipt.logs) {
      try {
        event.decodeResults(log.topics ?? [], log.data ?? '');
        if (log.topics != null && log.topics!.length > 1) {
          return EthereumAddress.fromHex(log.topics![1] as String).hex;
        }
      } catch (_) {}
    }

    // Fallback logic
    final fn = factory.function('allGroups');
    for (int i = 99; i >= 0; i--) {
      try {
        final result = await _client.call(
          contract: factory,
          function: fn,
          params: [BigInt.from(i)],
        );
        return (result.first as EthereumAddress).hex;
      } catch (_) {
        continue;
      }
    }

    throw Exception('Could not determine group address');
  }

  @override
  Future<BigInt> getCollateralAmount({required BigInt contribution, required int minGrade}) async {
    final factory = _factoryContract();
    final fn = factory.function('getCollateralAmount');
    final result = await _client.call(contract: factory, function: fn, params: [contribution, BigInt.from(minGrade)]);
    return result.first as BigInt;
  }

  @override
  Future<void> approveUsdc({required String spender, required BigInt amount}) async {
    final usdc = _erc20Contract(AppConstants.usdcAddress);
    await _sendTx(
      contract: usdc,
      functionName: 'approve',
      params: [EthereumAddress.fromHex(spender), amount],
    );
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Future<void> joinGroup({required String groupAddress}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'joinGroup',
      params: [],
      gasLimit: BigInt.from(300000),
    );
  }

  @override
  Future<void> startGroup({required String groupAddress}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'startGroup',
      params: [],
    );
  }

  @override
  Future<void> contribute({required String groupAddress}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'contribute',
      params: [],
      gasLimit: BigInt.from(600000),
    );
  }

  @override
  Future<void> flagDefaulter({required String groupAddress, required String memberAddress}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'flagDefaulter',
      params: [EthereumAddress.fromHex(memberAddress)],
      gasLimit: BigInt.from(500000),
    );
  }

  @override
  Future<void> castVote({required String groupAddress, required int vote}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'vote',
      params: [BigInt.from(vote)],
    );
  }

  @override
  Future<void> resolveVote({required String groupAddress}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'resolveVote',
      params: [],
    );
  }

  @override
  Future<GroupModel> getGroupDetails(String groupAddress) async {
    final contract = _groupContract(groupAddress);

    Future<List<dynamic>> readRaw(String fn, [List<dynamic> params = const []]) => _client
        .call(contract: contract, function: contract.function(fn), params: params);

    Future<dynamic> read(String fn, [List<dynamic> params = const []]) => readRaw(fn, params)
        .then((r) => r.first);

    final results = await Future.wait([
      readRaw('config'),        // 0: tuple (admin, factory, token, minGrade, contributionAmount, cycleDuration, maxMembers)
      read('currentCycle'),     // 1
      read('state'),            // 2
      readRaw('getMembers'),    // 3
      read('cycleStartTime'),   // 4
    ]);

    final config = results[0];
    final admin = (config[0] as EthereumAddress).hex;
    final token = (config[2] as EthereumAddress).hex;
    final minGrade = (config[3] as BigInt).toInt();
    final contributionAmount = config[4] as BigInt;
    final cycleDuration = config[5] as BigInt;
    final maxMembers = (config[6] as BigInt).toInt();

    final currentCycle = (results[1] as BigInt).toInt();
    final stateVal = (results[2] as BigInt).toInt();
    final members = ((results[3] as List).first as List<dynamic>).map((e) => (e as EthereumAddress).hex).toList();
    final cycleStartTime = (results[4] as BigInt).toInt();

    // Compute cycleDeadline = cycleStartTime + cycleDuration
    final cycleDeadline = cycleStartTime + cycleDuration.toInt();

    String recipient = '';
    try {
      final recipientResult = await _client.call(
        contract: contract,
        function: contract.function('getCurrentRecipient'),
        params: [],
      );
      recipient = (recipientResult.first as EthereumAddress).hex;
    } catch (_) {}

    return GroupModel(
      address: groupAddress,
      admin: admin,
      contributionAmount: contributionAmount,
      cycleDuration: cycleDuration,
      maxMembers: maxMembers,
      currentCycle: currentCycle,
      state: stateVal.toGroupState(),
      members: members,
      currentRecipient: recipient,
      cycleDeadline: cycleDeadline,
      minGrade: minGrade,
      token: token,
    );
  }

  @override
  Future<CycleProgressModel> getCycleProgress(String groupAddress) async {
    final contract = _groupContract(groupAddress);
    final result = await _client.call(
      contract: contract,
      function: contract.function('getCycleProgress'),
      params: [],
    );
    return CycleProgressModel(
      contributed: (result[0] as BigInt).toInt(),
      total: (result[1] as BigInt).toInt(),
    );
  }

  @override
  Future<List<MemberModel>> getMembers(String groupAddress) async {
    final contract = _groupContract(groupAddress);
    
    // 1. Fetch member addresses from contract
    final membersResult = await _client.call(
      contract: contract,
      function: contract.function('getMembers'),
      params: [],
    );
    
    final addresses = (membersResult.first as List<dynamic>)
        .map((e) => (e as EthereumAddress).hex)
        .toList();

    if (addresses.isEmpty) return [];

    // 2. Fetch current cycle
    final currentCycleResult = await _client.call(
      contract: contract,
      function: contract.function('currentCycle'),
      params: [],
    );
    final currentCycle = currentCycleResult.first as BigInt;
    
    // 3. For each member found, fetch their up-to-date state flags concurrently
    final List<MemberModel> models = [];
    final futures = addresses.map((addrHex) async {
      final addr = EthereumAddress.fromHex(addrHex);

      final mResFuture = _client.call(
        contract: contract,
        function: contract.function('members'),
        params: [addr],
      );
      
      final hasContributedFuture = _client.call(
        contract: contract,
        function: contract.function('hasContributedThisCycle'),
        params: [currentCycle, addr],
      );
      
      final results = await Future.wait([mResFuture, hasContributedFuture]);
      final mRes = results[0];
      final hasContributedResult = results[1];

      return MemberModel(
        address: addrHex,
        hasJoined: mRes[0] as bool,
        hasCollected: mRes[1] as bool,
        hasDefaulted: mRes[2] as bool,
        isLeaving: mRes[3] as bool,
        collateralDeposited: mRes[4] as BigInt,
        hasContributed: hasContributedResult.first as bool,
      );
    });

    models.addAll(await Future.wait(futures));
    return models;
  }

  @override
  Future<bool> hasContributed({required String groupAddress, required String memberAddress}) async {
    final contract = _groupContract(groupAddress);
    
    final currentCycleResult = await _client.call(
      contract: contract,
      function: contract.function('currentCycle'),
      params: [],
    );
    final currentCycle = currentCycleResult.first as BigInt;
    
    final result = await _client.call(
      contract: contract,
      function: contract.function('hasContributedThisCycle'),
      params: [currentCycle, EthereumAddress.fromHex(memberAddress)],
    );
    return result.first as bool;
  }

  @override
  Future<String> getCurrentRecipient(String groupAddress) async {
    final contract = _groupContract(groupAddress);
    final result = await _client.call(
      contract: contract,
      function: contract.function('getCurrentRecipient'),
      params: [],
    );
    return (result.first as EthereumAddress).hex;
  }

  Future<void> _syncGroupsOnChain(List<GroupModel> groups) async {
    if (groups.isEmpty) return;
    
    final futures = <Future<void>>[];
    for (int i = 0; i < groups.length; i++) {
      futures.add(() async {
        try {
          final g = groups[i];
          final contract = _groupContract(g.address);
          
          final stateFuture = _client.call(contract: contract, function: contract.function('state'), params: []);
          final cycleFuture = _client.call(contract: contract, function: contract.function('currentCycle'), params: []);
          final startTimeFuture = _client.call(contract: contract, function: contract.function('cycleStartTime'), params: []);
          final configFuture = _client.call(contract: contract, function: contract.function('config'), params: []);
          final membersFuture = _client.call(contract: contract, function: contract.function('getMembers'), params: []);
          
          final results = await Future.wait([stateFuture, cycleFuture, startTimeFuture, configFuture, membersFuture]);
          
          final stateInt = (results[0].first as BigInt).toInt();
          final currentCycle = (results[1].first as BigInt).toInt();
          final cycleStartTime = results[2].first as BigInt;
          
          final configList = results[3];
          final adminAddr = (configList[0] as EthereumAddress).hex;
          final tokenAddr = (configList[2] as EthereumAddress).hex;
          final minG = (configList[3] as BigInt).toInt();
          final contributionAmt = configList[4] as BigInt;
          final cycleDur = configList[5] as BigInt;
          final maxMems = (configList[6] as BigInt).toInt();
          
          final membersList = ((results[4] as List).first as List<dynamic>)
              .map((e) => (e as EthereumAddress).hex)
              .toList();
          
          int cycleDeadline = 0;
          if (stateInt == AppConstants.stateActive) {
            cycleDeadline = cycleStartTime.toInt() + cycleDur.toInt();
          }
          
          groups[i] = g.copyWith(
            admin: adminAddr,
            token: tokenAddr,
            minGrade: minG,
            state: stateInt.toGroupState(),
            currentCycle: currentCycle,
            cycleDeadline: cycleDeadline,
            contributionAmount: contributionAmt,
            cycleDuration: cycleDur,
            maxMembers: maxMems,
            members: membersList,
          );
        } catch (e) {
          print('DEBUG: Error syncing on-chain state for group ${groups[i].address}: $e');
        }
      }());
    }
    await Future.wait(futures);
  }

  @override
  Future<List<GroupModel>> getUserGroups(String walletAddress) async {
    final supabase = sl<SupabaseClient>();
    print('DEBUG: Fetching user groups for $walletAddress');
    try {
      final response = await supabase
          .from('group_members')
          .select('group_address, collateral_amount') // REMOVED groups(*) because FK was dropped
          .eq('member_address', walletAddress.toLowerCase());

      print('DEBUG: getUserGroups Supabase response: $response');

      final List<GroupModel> userGroups = [];
      for (final row in response) {
        userGroups.add(GroupModel(
          address: row['group_address'],
          admin: '',
          contributionAmount: BigInt.zero,
          cycleDuration: BigInt.zero,
          maxMembers: 0,
          currentCycle: 0,
          state: GroupState.pending,
          members: const [], 
          currentRecipient: '',
          cycleDeadline: 0,
          minGrade: 0,
          token: '',
        ));
      }
      
      await _syncGroupsOnChain(userGroups);
      
      return userGroups;
    } catch (e, st) {
      print('DEBUG: Error in getUserGroups: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<GroupModel>> getCreatedGroups(String walletAddress) async {
    final supabase = sl<SupabaseClient>();
    print('DEBUG: Fetching created groups for $walletAddress');
    try {
      final response = await supabase
          .from('groups')
          .select()
          .eq('creator_address', walletAddress.toLowerCase());

      print('DEBUG: getCreatedGroups Supabase response: $response');

      final List<GroupModel> createdGroups = [];
      for (final row in response) {
        createdGroups.add(GroupModel(
          address: row['group_address'],
          admin: row['creator_address'] ?? '',
          contributionAmount: BigInt.tryParse(row['contribution_amount']?.toString() ?? '0') ?? BigInt.zero,
          cycleDuration: BigInt.tryParse(row['cycle_duration']?.toString() ?? '0') ?? BigInt.zero,
          maxMembers: row['max_members'] ?? 0,
          currentCycle: row['current_cycle'] ?? 0,
          state: (row['state'] as int? ?? 0).toGroupState(),
          members: const [], // Detailed members not populated unless needed
          currentRecipient: row['current_recipient'] ?? '',
          cycleDeadline: row['cycle_deadline'] ?? 0,
          minGrade: row['min_grade'] ?? 0,
          token: row['token_address'] ?? '',
        ));
      }
      
      await _syncGroupsOnChain(createdGroups);
      
      return createdGroups;
    } catch (e, st) {
      print('DEBUG: Error in getCreatedGroups: $e\n$st');
      rethrow;
    }
  }
}