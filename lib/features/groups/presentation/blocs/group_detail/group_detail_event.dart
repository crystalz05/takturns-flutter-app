import 'package:equatable/equatable.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();
  @override List<Object?> get props => [];
}

class LoadGroupDetailEvent extends GroupDetailEvent {
  final String groupAddress;
  const LoadGroupDetailEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class RefreshGroupDetailEvent extends GroupDetailEvent {
  final String groupAddress;
  const RefreshGroupDetailEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class StartGroupEvent extends GroupDetailEvent {
  final String groupAddress;
  const StartGroupEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class ContributeEvent extends GroupDetailEvent {
  final String groupAddress;
  const ContributeEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class FlagDefaulterEvent extends GroupDetailEvent {
  final String groupAddress;
  final String memberAddress;
  const FlagDefaulterEvent({required this.groupAddress, required this.memberAddress});
  @override List<Object?> get props => [groupAddress, memberAddress];
}

class CastVoteEvent extends GroupDetailEvent {
  final String groupAddress;
  final int vote;
  const CastVoteEvent({required this.groupAddress, required this.vote});
  @override List<Object?> get props => [groupAddress, vote];
}

class ResolveVoteEvent extends GroupDetailEvent {
  final String groupAddress;
  const ResolveVoteEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}
