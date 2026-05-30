import 'package:takturns_flutter_app/features/wallet/domain/entities/wallet_info.dart';

class WalletModel extends WalletInfo {
  const WalletModel({
    required super.address,
    required super.usdcBalance,
    required super.grade,
    required super.consecutiveCompletions,
    required super.isBlacklisted
  });

  factory WalletModel.fromWeb3(
      String address,
      BigInt usdcBalance,
      int grade,
      int consecutiveCompletions,
      bool isBlacklisted){
    return WalletModel(
      address: address,
      usdcBalance: usdcBalance,
      grade: grade,
      consecutiveCompletions: consecutiveCompletions,
      isBlacklisted: isBlacklisted
    );
  }
}