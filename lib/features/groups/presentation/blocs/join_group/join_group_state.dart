
import 'package:equatable/equatable.dart';

import '../../../domain/entities/group.dart';

abstract class JoinGroupState extends Equatable {
  const JoinGroupState();
  @override List<Object?> get props => [];
}

class JoinGroupInitial extends JoinGroupState {}
class JoinGroupLoadingPreview extends JoinGroupState {}
class JoinGroupPreviewLoaded extends JoinGroupState {
  final Group group;
  final BigInt collateral;
  const JoinGroupPreviewLoaded({required this.group, required this.collateral});
  @override List<Object?> get props => [group, collateral];
}
class JoinGroupJoining extends JoinGroupState {
  final String message;
  const JoinGroupJoining(this.message);
  @override List<Object?> get props => [message];
}
class JoinGroupSuccess extends JoinGroupState {
  final String groupAddress;
  const JoinGroupSuccess(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}
class JoinGroupError extends JoinGroupState {
  final String message;
  const JoinGroupError(this.message);
  @override List<Object?> get props => [message];
}
