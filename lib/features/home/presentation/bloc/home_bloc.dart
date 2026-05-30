import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';

import 'home_event.dart';
import 'home_state.dart';

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
