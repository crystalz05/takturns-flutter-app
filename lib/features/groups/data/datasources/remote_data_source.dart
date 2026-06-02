import 'dart:developer';

import 'package:web3dart/web3dart.dart';
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
    required EthPrivateKey credentials,
  });
  Future<BigInt> getCollateralAmount({required BigInt contribution, required int minGrade});
  Future<void> approveUsdc({required String spender, required BigInt amount, required EthPrivateKey credentials});
  Future<void> joinGroup({required String groupAddress, required EthPrivateKey credentials});
  Future<void> startGroup({required String groupAddress, required EthPrivateKey credentials});
  Future<void> contribute({required String groupAddress, required EthPrivateKey credentials});
  Future<void> flagDefaulter({required String groupAddress, required String memberAddress, required EthPrivateKey credentials});
  Future<void> castVote({required String groupAddress, required int vote, required EthPrivateKey credentials});
  Future<void> resolveVote({required String groupAddress, required EthPrivateKey credentials});
  Future<GroupModel> getGroupDetails(String groupAddress);
  Future<CycleProgressModel> getCycleProgress(String groupAddress);
  Future<List<MemberModel>> getMembers(String groupAddress);
  Future<bool> hasContributed({required String groupAddress, required String memberAddress});
  Future<String> getCurrentRecipient(String groupAddress);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final Web3Client _client;

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
    required EthPrivateKey credentials,
    BigInt? gasLimit,
  }) async {
    final fn = contract.function(functionName);
    final tx = Transaction.callContract(
      contract: contract,
      function: fn,
      parameters: params,
      maxGas: gasLimit?.toInt() ?? 500000,
      maxFeePerGas: EtherAmount.inWei(BigInt.from(100000000)), // 0.1 Gwei
      maxPriorityFeePerGas: EtherAmount.inWei(BigInt.zero),
    );
    return _client.sendTransaction(
      credentials,
      tx,
      chainId: AppConstants.chainId,
    );
  }

  // ─── Implementation ────────────────────────────────────────────────────────

  @override
  Future<String> createGroup({
    required int minGrade,
    required BigInt contributionAmount,
    required BigInt cycleDuration,
    required int maxMembers,
    required String token,
    required EthPrivateKey credentials,
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
      credentials: credentials,
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
  Future<void> approveUsdc({required String spender, required BigInt amount, required EthPrivateKey credentials}) async {
    final usdc = _erc20Contract(AppConstants.usdcAddress);
    await _sendTx(
      contract: usdc,
      functionName: 'approve',
      params: [EthereumAddress.fromHex(spender), amount],
      credentials: credentials,
    );
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Future<void> joinGroup({required String groupAddress, required EthPrivateKey credentials}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'joinGroup',
      params: [],
      credentials: credentials,
      gasLimit: BigInt.from(300000),
    );
  }

  @override
  Future<void> startGroup({required String groupAddress, required EthPrivateKey credentials}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'startGroup',
      params: [],
      credentials: credentials,
    );
  }

  @override
  Future<void> contribute({required String groupAddress, required EthPrivateKey credentials}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'contribute',
      params: [],
      credentials: credentials,
      gasLimit: BigInt.from(600000),
    );
  }

  @override
  Future<void> flagDefaulter({required String groupAddress, required String memberAddress, required EthPrivateKey credentials}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'flagDefaulter',
      params: [EthereumAddress.fromHex(memberAddress)],
      credentials: credentials,
      gasLimit: BigInt.from(500000),
    );
  }

  @override
  Future<void> castVote({required String groupAddress, required int vote, required EthPrivateKey credentials}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'vote',
      params: [BigInt.from(vote)],
      credentials: credentials,
    );
  }

  @override
  Future<void> resolveVote({required String groupAddress, required EthPrivateKey credentials}) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'resolveVote',
      params: [],
      credentials: credentials,
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
    final membersResult = await _client.call(
      contract: contract,
      function: contract.function('getMembers'),
      params: [],
    );
    final addresses = (membersResult.first as List<dynamic>).map((e) => (e as EthereumAddress).hex).toList();

    // Read current cycle for hasContributedThisCycle
    final cycleResult = await _client.call(
      contract: contract,
      function: contract.function('currentCycle'),
      params: [],
    );
    final currentCycle = cycleResult.first as BigInt;

    return await Future.wait(
      addresses.map((addr) async {
        bool contributed = false;
        try {
          final contribResult = await _client.call(
            contract: contract,
            function: contract.function('hasContributedThisCycle'),
            params: [currentCycle, EthereumAddress.fromHex(addr)],
          );
          contributed = contribResult.first as bool;
        } catch (_) {}

        return MemberModel(
          address: addr,
          hasContributedThisCycle: contributed,
          totalContributed: BigInt.zero, // No longer available from contract
        );
      }),
    );
  }

  @override
  Future<bool> hasContributed({required String groupAddress, required String memberAddress}) async {
    final contract = _groupContract(groupAddress);
    // Read current cycle
    final cycleResult = await _client.call(
      contract: contract,
      function: contract.function('currentCycle'),
      params: [],
    );
    final currentCycle = cycleResult.first as BigInt;

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
}