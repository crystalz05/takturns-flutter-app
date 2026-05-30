import 'package:dartz/dartz.dart';
import 'package:takturns_flutter_app/core/errors/failures.dart';
import 'package:takturns_flutter_app/core/usecases/usecase.dart';
import 'package:takturns_flutter_app/features/wallet/domain/entities/wallet_info.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';

class ConnectWallet extends Usecase<WalletInfo, String> {
  final WalletRepository repository;
  ConnectWallet({required this.repository});

  @override
  Future<Either<Failure, WalletInfo>> call(String privateKey) => repository.connectWallet(privateKey);
}

class GetStoredWallet extends Usecase<WalletInfo?, NoParams> {
  final WalletRepository repository;
  GetStoredWallet({required this.repository});

  @override
  Future<Either<Failure, WalletInfo?>> call(NoParams params) => repository.getStoredWallet();
}

class GetUsdcBalance extends Usecase<BigInt, String> {
  final WalletRepository repository;
  GetUsdcBalance({required this.repository});

  @override
  Future<Either<Failure, BigInt>> call(String address) => repository.getUsdcBalance(address);
}

class DisconnectWallet extends Usecase<void, NoParams> {
  final WalletRepository repository;
  DisconnectWallet({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) => repository.disconnect();
}
