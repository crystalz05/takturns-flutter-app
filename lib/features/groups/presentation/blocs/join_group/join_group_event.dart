
import 'package:equatable/equatable.dart';

abstract class JoinGroupEvent extends Equatable {
  const JoinGroupEvent();
  @override List<Object?> get props => [];
}

class PreviewGroupEvent extends JoinGroupEvent {
  final String groupAddress;
  const PreviewGroupEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class ConfirmJoinEvent extends JoinGroupEvent {
  final String groupAddress;
  const ConfirmJoinEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}
