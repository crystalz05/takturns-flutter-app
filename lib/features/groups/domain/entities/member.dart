import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String address;
  final bool hasContributedThisCycle;
  final BigInt totalContributed;

  const Member({
    required this.address,
    required this.hasContributedThisCycle,
    required this.totalContributed,
  });

  @override
  List<Object?> get props => [address, hasContributedThisCycle, totalContributed];
}
