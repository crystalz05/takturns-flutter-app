import 'package:shared_preferences/shared_preferences.dart';
import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/wallet/data/models/wallet_model.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:takturns_flutter_app/core/di/injection_container.dart';

import '../../../../core/constants/abis.dart';

abstract class WalletDatasource {
  Future<WalletModel?> connectWallet(String _);
  Future<WalletModel?> getStoredWallet();
  Future<BigInt> getUsdcBalance(String address);
  Future<void> disconnect();
  String? get currentAddress;
}

class WalletDataSourceImpl extends WalletDatasource {

  late final Web3Client _client;
  final SharedPreferences _prefs;
  
  ReownAppKitModal get _appKit => sl<ReownAppKitModal>();
  
  WalletModel? _cachedWallet;

  WalletDataSourceImpl(this._prefs) {
    _client = Web3Client(AppConstants.rpcUrl, http.Client());
  }

  @override
  Future<WalletModel?> connectWallet(String _) async {
    // connect is handled by the AppKitModalConnectButton UI. 
    // This just returns the current model if connected.
    if (_appKit.session != null) {
      return _buildWalletModel();
    }
    return null;
  }

  @override
  String? get currentAddress {
    final String? address = _appKit.session?.getAddress('eip155');
    if (address != null && address.contains(':')) {
      // Reown appkit addresses are formatted as "namespace:chainId:address" e.g. "eip155:1:0x123..."
      return address.split(':').last;
    }
    return address;
  }

  @override
  Future<void> disconnect() async {
    _cachedWallet = null;
    if (_appKit.session != null) {
      await _appKit.disconnect();
    }
  }

  @override
  Future<WalletModel?> getStoredWallet() async {
    try{
      if (_appKit.session != null) {
        return _buildWalletModel();
      }
      return null;
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
    final address = currentAddress;
    if (address == null) throw Exception("No connected address");
    
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