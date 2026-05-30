import 'package:dartz/dartz.dart';
import 'package:takturns_flutter_app/features/wallet/domain/entities/wallet_info.dart';

import '../../../../core/errors/failures.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletInfo>> connectWallet(String privateKey);
  Future<Either<Failure, WalletInfo?>> getStoredWallet();
  Future<Either<Failure, BigInt>> getUsdcBalance(String address);
  Future<Either<Failure, void>> disconnect();
  String? get currentAddress;
}
