import 'package:equatable/equatable.dart';

abstract class CreateGroupState extends Equatable {
  const CreateGroupState();
  @override List<Object?> get props => [];
}

class CreateGroupInitial extends CreateGroupState {}
class CreateGroupLoading extends CreateGroupState {
  final String message;
  const CreateGroupLoading(this.message);
  @override List<Object?> get props => [message];
}
class CreateGroupSuccess extends CreateGroupState {
  final String groupAddress;
  const CreateGroupSuccess(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}
class CreateGroupError extends CreateGroupState {
  final String message;
  const CreateGroupError(this.message);
  @override List<Object?> get props => [message];
}
