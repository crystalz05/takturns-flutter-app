import 'package:shared_preferences/shared_preferences.dart';
import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/wallet/data/models/wallet_model.dart';
import 'package:takturns_flutter_app/features/wallet/domain/entities/wallet_info.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/abis.dart';

abstract class WalletDatasource {
  Future<WalletModel> connectWallet(String privatKey);
  Future<WalletModel?> getStoredWallet();
  Future<BigInt> getUsdcBalance(String address);
  Future<void> disconnect();
  String? get currentAddress;
}

const _pkKey = 'wallet_private_key';

class WalletDataSourceImpl extends WalletDatasource {

  late final Web3Client _client;
  EthPrivateKey? _credentials;
  final SharedPreferences _prefs;
  EthPrivateKey? get credentials => _credentials;
  WalletModel? _cachedWallet;

  WalletDataSourceImpl(this._prefs){
    _client = Web3Client(AppConstants.rpcUrl, http.Client());
  }

  @override
  Future<WalletModel> connectWallet(String privateKey) async {
    try{
      final normalised = privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey;
      _credentials = EthPrivateKey.fromHex(normalised);
      await _prefs.setString(_pkKey, normalised);
      return _buildWalletModel();
    }catch (e){
      throw Exception("Failed to connect wallet: $e");
    }
  }

  @override
  String? get currentAddress => _credentials?.address.hex;

  @override
  Future<void> disconnect() async {
    _credentials = null;
    _cachedWallet = null;
    _prefs.remove(_pkKey);
  }

  @override
  Future<WalletModel?> getStoredWallet() async {
    try{
      final stored = _prefs.getString(_pkKey);
      if (stored == null) return null;
      _credentials = EthPrivateKey.fromHex(stored);
      return _buildWalletModel();
    }catch (e){
      throw Exception("Failed to get stored wallet: $e");
    }
  }

  @override
  Future<BigInt> getUsdcBalance(String address) async {
    try{
      final contract = DeployedContract(
        ContractAbi.fromJson(ContractAbis.erc20, 'USDC'),
        EthereumAddress.fromHex(AppConstants.usdcAddress),
      );
      final fn = contract.function('balanceOf');
      final result = await _client.call(
        contract: contract,
        function: fn,
        params: [EthereumAddress.fromHex(address)],
      );
      return result.first as BigInt;
    }catch(e){
      throw Exception("Failed to get USDC balance: $e");
    }
  }

  Future<WalletModel> _buildWalletModel() async {
    final address = _credentials!.address.hex;
    final usdcBalance = await getUsdcBalance(address);

    // Fetch member profile from factory
    final factory = DeployedContract(
      ContractAbi.fromJson(ContractAbis.factory, 'TakturnsFactory'),
      EthereumAddress.fromHex(AppConstants.factoryAddress),
    );
    final profileFn = factory.function('getMemberProfile');
    final profileResult = await _client.call(
      contract: factory,
      function: profileFn,
      params: [EthereumAddress.fromHex(address)],
    );

    // Result is a tuple: (grade, consecutiveCompletions, isBlacklisted)
    final profile = profileResult.first as List<dynamic>;
    final grade = (profile[0] as BigInt).toInt();
    final consecutiveCompletions = (profile[1] as BigInt).toInt();
    final isBlacklisted = profile[2] as bool;

    _cachedWallet = WalletModel.fromWeb3(
      address,
      usdcBalance,
      grade,
      consecutiveCompletions,
      isBlacklisted,
    );
    return _cachedWallet!;
  }
}