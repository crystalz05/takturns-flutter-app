import 'package:equatable/equatable.dart';

import '../../../domain/entities/cycle_progress.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/entities/member.dart';

abstract class GroupDetailState extends Equatable {
  const GroupDetailState();
  @override List<Object?> get props => [];
}

class GroupDetailInitial extends GroupDetailState {}
class GroupDetailLoading extends GroupDetailState {}

class GroupDetailLoaded extends GroupDetailState {
  final Group group;
  final CycleProgress cycleProgress;
  final List<Member> members;
  final bool myContributed;
  final String myAddress;

  const GroupDetailLoaded({
    required this.group,
    required this.cycleProgress,
    required this.members,
    required this.myContributed,
    required this.myAddress,
  });

  bool get isAdmin => group.admin.toLowerCase() == myAddress.toLowerCase();
  bool get isMyTurn =>
      group.currentRecipient.toLowerCase() == myAddress.toLowerCase();

  @override
  List<Object?> get props => [group, cycleProgress, members, myContributed, myAddress];
}

class GroupDetailTransacting extends GroupDetailState {
  final String message;
  final GroupDetailLoaded previousState;
  const GroupDetailTransacting({required this.message, required this.previousState});
  @override List<Object?> get props => [message];
}

class GroupDetailError extends GroupDetailState {
  final String message;
  const GroupDetailError(this.message);
  @override List<Object?> get props => [message];
}

class GroupDetailTxSuccess extends GroupDetailState {
  final String message;
  final GroupDetailLoaded data;
  const GroupDetailTxSuccess({required this.message, required this.data});
  @override List<Object?> get props => [message, data];
}
