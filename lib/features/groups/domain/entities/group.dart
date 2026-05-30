import 'package:equatable/equatable.dart';

enum GroupState { pending, active, completed, dissolved }

extension GroupStateExt on int {
  GroupState toGroupState() {
    switch (this) {
      case 0: return GroupState.pending;
      case 1: return GroupState.active;
      case 2: return GroupState.completed;
      case 3: return GroupState.dissolved;
      default: return GroupState.pending;
    }
  }
}

class Group extends Equatable {
  final String address;
  final String admin;
  final BigInt contributionAmount;
  final BigInt cycleDuration;
  final int maxMembers;
  final int currentCycle;
  final GroupState state;
  final List<String> members;
  final String currentRecipient;
  final int cycleDeadline;
  final int minGrade;
  final String token;

  const Group({
    required this.address,
    required this.admin,
    required this.contributionAmount,
    required this.cycleDuration,
    required this.maxMembers,
    required this.currentCycle,
    required this.state,
    required this.members,
    required this.currentRecipient,
    required this.cycleDeadline,
    required this.minGrade,
    required this.token,
  });

  bool get isFull => members.length >= maxMembers;
  bool get isPending => state == GroupState.pending;
  bool get isActive => state == GroupState.active;
  bool get isCompleted => state == GroupState.completed;
  bool get isDissolved => state == GroupState.dissolved;

  @override
  List<Object?> get props => [
    address, admin, contributionAmount, cycleDuration,
    maxMembers, currentCycle, state, members, currentRecipient,
    cycleDeadline, minGrade, token,
  ];
}
