import 'package:web3dart/web3dart.dart';
import 'package:takturns_flutter_app/core/constants/abis.dart';
import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/cycle_progress.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/member.dart';
import 'package:takturns_flutter_app/features/groups/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final Web3Client _client;
  final EthPrivateKey Function() _getCredentials;
  EthPrivateKey getCredentials() => _getCredentials();

  GroupRepositoryImpl(this._client, this._getCredentials);

  // ─── Helpers ─────────────────────────────────────────────────────────────────

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
    final fn = contract.function(functionName);
    final tx = Transaction.callContract(
      contract: contract,
      function: fn,
      parameters: params,
      maxGas: gasLimit?.toInt() ?? 500000,
    );
    return _client.sendTransaction(
      _getCredentials(),
      tx,
      chainId: AppConstants.chainId,
    );
  }

  // ─── Factory ──────────────────────────────────────────────────────────────────

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

    // Wait for receipt and extract GroupCreated event
    TransactionReceipt? receipt;
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      receipt = await _client.getTransactionReceipt(txHash);
      if (receipt != null) break;
    }

    if (receipt == null) throw Exception('Transaction not mined');

    // Parse GroupCreated event log to get group address
    final event = factory.event('GroupCreated');
    for (final log in receipt.logs) {
      try {
        event.decodeResults(log.topics ?? [], log.data ?? '');
        // groupAddress is the first indexed topic
        if (log.topics != null && log.topics!.length > 1) {
          final groupAddr = EthereumAddress.fromHex(log.topics![1] as String).hex;
          return groupAddr;
        }
      } catch (_) {}
    }

    // Fallback: read from allGroups array
    final fn = factory.function('allGroups');
    // Get the last group (most recently created)
    try {
      // Try index 0, 1, 2... until we get an error
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
    } catch (_) {}

    throw Exception('Could not determine group address');
  }

  @override
  Future<BigInt> getCollateralAmount({
    required BigInt contribution,
    required int minGrade,
  }) async {
    final factory = _factoryContract();
    final fn = factory.function('getCollateralAmount');
    final result = await _client.call(
      contract: factory,
      function: fn,
      params: [contribution, BigInt.from(minGrade)],
    );
    return result.first as BigInt;
  }

  // ─── USDC Approval ────────────────────────────────────────────────────────────

  @override
  Future<void> approveUsdc({
    required String spender,
    required BigInt amount,
  }) async {
    final usdc = _erc20Contract(AppConstants.usdcAddress);
    await _sendTx(
      contract: usdc,
      functionName: 'approve',
      params: [EthereumAddress.fromHex(spender), amount],
    );
    // Wait a moment for approval to propagate
    await Future.delayed(const Duration(seconds: 3));
  }

  // ─── Group Operations ─────────────────────────────────────────────────────────

  @override
  Future<void> joinGroup(String groupAddress) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'joinGroup',
      params: [],
      gasLimit: BigInt.from(300000),
    );
  }

  @override
  Future<void> startGroup(String groupAddress) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'startGroup',
      params: [],
    );
  }

  @override
  Future<void> contribute(String groupAddress) async {
    // Use higher gas limit in case this is the final contribution (triggers distribution)
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'contribute',
      params: [],
      gasLimit: BigInt.from(600000),
    );
  }

  @override
  Future<void> flagDefaulter({
    required String groupAddress,
    required String memberAddress,
  }) async {
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
      functionName: 'castVote',
      params: [BigInt.from(vote)],
    );
  }

  @override
  Future<void> resolveVote(String groupAddress) async {
    await _sendTx(
      contract: _groupContract(groupAddress),
      functionName: 'resolveVote',
      params: [],
    );
  }

  // ─── Queries ──────────────────────────────────────────────────────────────────

  @override
  Future<Group> getGroupDetails(String groupAddress) async {
    final contract = _groupContract(groupAddress);

    Future<dynamic> read(String fn, [List<dynamic> params = const []]) => _client
        .call(contract: contract, function: contract.function(fn), params: params)
        .then((r) => r.first);

    final results = await Future.wait([
      read('admin'),
      read('contributionAmount'),
      read('cycleDuration'),
      read('maxMembers'),
      read('currentCycle'),
      read('state'),
      read('getMembers'),
      read('cycleDeadline'),
      read('minGrade'),
      read('token'),
    ]);

    final members = (results[6] as List<dynamic>)
        .map((e) => (e as EthereumAddress).hex)
        .toList();

    String recipient = '';
    try {
      final recipientResult = await _client.call(
        contract: contract,
        function: contract.function('getCurrentRecipient'),
        params: [],
      );
      recipient = (recipientResult.first as EthereumAddress).hex;
    } catch (_) {}

    return Group(
      address: groupAddress,
      admin: (results[0] as EthereumAddress).hex,
      contributionAmount: results[1] as BigInt,
      cycleDuration: results[2] as BigInt,
      maxMembers: (results[3] as BigInt).toInt(),
      currentCycle: (results[4] as BigInt).toInt(),
      state: (results[5] as BigInt).toInt().toGroupState(),
      members: members,
      currentRecipient: recipient,
      cycleDeadline: (results[7] as BigInt).toInt(),
      minGrade: (results[8] as BigInt).toInt(),
      token: (results[9] as EthereumAddress).hex,
    );
  }

  @override
  Future<CycleProgress> getCycleProgress(String groupAddress) async {
    final contract = _groupContract(groupAddress);
    final fn = contract.function('getCycleProgress');
    final result = await _client.call(
      contract: contract,
      function: fn,
      params: [],
    );
    return CycleProgress(
      contributed: (result[0] as BigInt).toInt(),
      total: (result[1] as BigInt).toInt(),
    );
  }

  @override
  Future<List<Member>> getMembers(String groupAddress) async {
    final contract = _groupContract(groupAddress);
    final membersFn = contract.function('getMembers');
    final membersResult = await _client.call(
      contract: contract,
      function: membersFn,
      params: [],
    );
    final addresses = (membersResult.first as List<dynamic>)
        .map((e) => (e as EthereumAddress).hex)
        .toList();

    // Fetch contribution status for each member
    final members = await Future.wait(
      addresses.map((addr) async {
        bool contributed = false;
        BigInt total = BigInt.zero;
        try {
          final contribResult = await _client.call(
            contract: contract,
            function: contract.function('hasContributed'),
            params: [EthereumAddress.fromHex(addr)],
          );
          contributed = contribResult.first as bool;

          final totalResult = await _client.call(
            contract: contract,
            function: contract.function('totalContributed'),
            params: [EthereumAddress.fromHex(addr)],
          );
          total = totalResult.first as BigInt;
        } catch (_) {}

        return Member(
          address: addr,
          hasContributedThisCycle: contributed,
          totalContributed: total,
        );
      }),
    );

    return members;
  }

  @override
  Future<bool> hasContributed({
    required String groupAddress,
    required String memberAddress,
  }) async {
    final contract = _groupContract(groupAddress);
    final fn = contract.function('hasContributed');
    final result = await _client.call(
      contract: contract,
      function: fn,
      params: [EthereumAddress.fromHex(memberAddress)],
    );
    return result.first as bool;
  }

  @override
  Future<String> getCurrentRecipient(String groupAddress) async {
    final contract = _groupContract(groupAddress);
    final fn = contract.function('getCurrentRecipient');
    final result = await _client.call(
      contract: contract,
      function: fn,
      params: [],
    );
    return (result.first as EthereumAddress).hex;
  }
}
