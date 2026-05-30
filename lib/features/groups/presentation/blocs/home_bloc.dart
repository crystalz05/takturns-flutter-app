import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';

// Simple home bloc that reads saved group addresses from prefs and loads them

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

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetGroupDetails getGroupDetails;
  static const _prefsKey = 'saved_group_addresses';

  HomeBloc({required this.getGroupDetails}) : super(HomeInitial()) {
    on<LoadGroupsEvent>(_onLoad);
    on<AddGroupAddressEvent>(_onAddAddress);
  }

  Future<void> _onLoad(LoadGroupsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final addresses = prefs.getStringList(_prefsKey) ?? [];
      final groups = await Future.wait(
        addresses.map((addr) => getGroupDetails(addr)).toList(),
      );
      emit(HomeLoaded(groups.cast<Group>()));
    } catch (e) {
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddAddress(AddGroupAddressEvent event, Emitter<HomeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final addresses = List<String>.from(prefs.getStringList(_prefsKey) ?? []);
    if (!addresses.contains(event.address)) {
      addresses.add(event.address);
      await prefs.setStringList(_prefsKey, addresses);
    }
    add(const LoadGroupsEvent());
  }

  static Future<void> saveGroupAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    final addresses = List<String>.from(prefs.getStringList(_prefsKey) ?? []);
    if (!addresses.contains(address)) {
      addresses.add(address);
      await prefs.setStringList(_prefsKey, addresses);
    }
  }
}
