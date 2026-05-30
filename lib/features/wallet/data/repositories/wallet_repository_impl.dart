import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takturns_flutter_app/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:web3dart/web3dart.dart';
import 'package:takturns_flutter_app/core/constants/abis.dart';
import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/wallet/domain/entities/wallet_info.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';

import '../../../../core/errors/failures.dart';

const _pkKey = 'wallet_private_key';

class WalletRepositoryImpl implements WalletRepository {
  final WalletDatasource datasource;

  WalletRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, WalletInfo>> connectWallet(String privateKey) async {
    try{
      final wallet = await datasource.connectWallet(privateKey);
      return Right(wallet);
    }catch (e){
      return Left(WalletFailure(e.toString()));
    }
  }

  @override
  String? get currentAddress => datasource.currentAddress;

  @override
  Future<Either<Failure, void>> disconnect() async {
    try{
      await datasource.disconnect();
      return const Right(null);
    }catch (e){
      return Left(WalletFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletInfo?>> getStoredWallet() async {
    try{
      final wallet = await datasource.getStoredWallet();
      return Right(wallet);
    }catch (e){
      return Left(WalletFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BigInt>> getUsdcBalance(String address) async {
    try{
      final balance = await datasource.getUsdcBalance(address);
      return Right(balance);
    }catch (e){
      return Left(WalletFailure(e.toString()));
    }
  }
}


// class WalletRepositoryImpl implements WalletRepository {
//   final Web3Client _client;
//   final SharedPreferences _prefs;
//
//   EthPrivateKey? _credentials;
//   EthPrivateKey? get credentials => _credentials;
//   WalletInfo? _cachedWallet;
//
//   WalletRepositoryImpl(this._client, this._prefs);
//
//   @override
//   String? get currentAddress => _credentials?.address.hex;
//
//   @override
//   Future<WalletInfo> connectWallet(String privateKey) async {
//     final normalised = privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey;
//     _credentials = EthPrivateKey.fromHex(normalised);
//     await _prefs.setString(_pkKey, normalised);
//     return _buildWalletInfo();
//   }
//
//   @override
//   Future<WalletInfo?> getStoredWallet() async {
//     final stored = _prefs.getString(_pkKey);
//     if (stored == null) return null;
//     _credentials = EthPrivateKey.fromHex(stored);
//     return _buildWalletInfo();
//   }
//
//   @override
//   Future<BigInt> getUsdcBalance(String address) async {
//     final contract = DeployedContract(
//       ContractAbi.fromJson(ContractAbis.erc20, 'USDC'),
//       EthereumAddress.fromHex(AppConstants.usdcAddress),
//     );
//     final fn = contract.function('balanceOf');
//     final result = await _client.call(
//       contract: contract,
//       function: fn,
//       params: [EthereumAddress.fromHex(address)],
//     );
//     return result.first as BigInt;
//   }
//
//   @override
//   Future<void> disconnect() async {
//     _credentials = null;
//     _cachedWallet = null;
//     await _prefs.remove(_pkKey);
//   }
//
//   Future<WalletInfo> _buildWalletInfo() async {
//     final address = _credentials!.address.hex;
//     final usdcBalance = await getUsdcBalance(address);
//
//     // Fetch member profile from factory
//     final factory = DeployedContract(
//       ContractAbi.fromJson(ContractAbis.factory, 'TakturnsFactory'),
//       EthereumAddress.fromHex(AppConstants.factoryAddress),
//     );
//     final profileFn = factory.function('getMemberProfile');
//     final profileResult = await _client.call(
//       contract: factory,
//       function: profileFn,
//       params: [EthereumAddress.fromHex(address)],
//     );
//
//     // Result is a tuple: (grade, consecutiveCompletions, isBlacklisted)
//     final profile = profileResult.first as List<dynamic>;
//     final grade = (profile[0] as BigInt).toInt();
//     final consecutiveCompletions = (profile[1] as BigInt).toInt();
//     final isBlacklisted = profile[2] as bool;
//
//     _cachedWallet = WalletInfo(
//       address: address,
//       usdcBalance: usdcBalance,
//       grade: grade,
//       consecutiveCompletions: consecutiveCompletions,
//       isBlacklisted: isBlacklisted,
//     );
//     return _cachedWallet!;
//   }
// }
