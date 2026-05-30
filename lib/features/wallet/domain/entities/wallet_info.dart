import 'package:equatable/equatable.dart';

class WalletInfo extends Equatable {
  final String address;
  final BigInt usdcBalance;
  final int grade;
  final int consecutiveCompletions;
  final bool isBlacklisted;

  const WalletInfo({
    required this.address,
    required this.usdcBalance,
    required this.grade,
    required this.consecutiveCompletions,
    required this.isBlacklisted,
  });

  int get displayGrade => grade == 0 ? 1 : grade;

  @override
  List<Object?> get props => [
    address, usdcBalance, grade, consecutiveCompletions, isBlacklisted,
  ];
}
