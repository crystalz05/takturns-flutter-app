import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override List<Object?> get props => [];
}

class LoadGroupsEvent extends HomeEvent {
  const LoadGroupsEvent();
}

class AddGroupAddressEvent extends HomeEvent {
  final String address;
  const AddGroupAddressEvent(this.address);
  @override List<Object?> get props => [address];
}
