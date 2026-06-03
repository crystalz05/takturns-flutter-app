import 'package:equatable/equatable.dart';

import '../../../groups/domain/entities/group.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override List<Object?> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<Group> joinedGroups;
  final List<Group> createdGroups;
  const HomeLoaded({required this.joinedGroups, required this.createdGroups});
  @override List<Object?> get props => [joinedGroups, createdGroups];
}
class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override List<Object?> get props => [message];
}
