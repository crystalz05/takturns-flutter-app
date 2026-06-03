import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String address;
  final bool hasJoined;
  final bool hasCollected;
  final bool hasDefaulted;
  final bool isLeaving;
  final BigInt collateralDeposited;
  final bool hasContributed;

  const Member({
    required this.address,
    required this.hasJoined,
    required this.hasCollected,
    required this.hasDefaulted,
    required this.isLeaving,
    required this.collateralDeposited,
    required this.hasContributed,
  });

  @override
  List<Object?> get props => [
    address,
    hasJoined,
    hasCollected,
    hasDefaulted,
    isLeaving,
    collateralDeposited,
    hasContributed,
  ];
}
