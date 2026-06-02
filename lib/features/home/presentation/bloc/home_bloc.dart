import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takturns_flutter_app/core/errors/failures.dart';
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
      final results = await Future.wait(
        addresses.map((addr) => getGroupDetails(addr)).toList(),
      );

      final List<Group> successfulGroups = [];
      Failure? firstFailure;

      for (final result in results) {
        result.fold(
              (failure) => firstFailure = failure, // Left side: Failure
              (group) => successfulGroups.add(group), // Right side: Success (Group)
        );
      }

      if (successfulGroups.isEmpty && firstFailure != null) {
        // If everything failed, or you want strict "fail on first error" behavior:
        emit(HomeError("Failed to load groups"));
      } else {
        // Pass the clean List<Group> to your state
        emit(HomeLoaded(successfulGroups));
      }
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
