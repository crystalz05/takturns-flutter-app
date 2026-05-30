import 'package:equatable/equatable.dart';

import '../../../groups/domain/entities/group.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override List<Object?> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<Group> groups;
  const HomeLoaded(this.groups);
  @override List<Object?> get props => [groups];
}
class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override List<Object?> get props => [message];
}
