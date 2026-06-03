import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:takturns_flutter_app/core/errors/failures.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserGroups getUserGroups;
  final GetCreatedGroups getCreatedGroups;

  HomeBloc({required this.getUserGroups, required this.getCreatedGroups}) : super(HomeInitial()) {
    on<LoadGroupsEvent>(_onLoad);
    on<AddGroupAddressEvent>(_onAddAddress);
  }

  Future<void> _onLoad(LoadGroupsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        getUserGroups(event.walletAddress),
        getCreatedGroups(event.walletAddress),
      ]);

      final joinedResult = results[0];
      final createdResult = results[1];

      joinedResult.fold(
        (failure) {
          debugPrint('Error fetching joined groups: ${failure.message}');
          emit(HomeError('Joined groups error: ${failure.message}'));
        },
        (joinedGroups) {
          createdResult.fold(
            (failure) {
              debugPrint('Error fetching created groups: ${failure.message}');
              emit(HomeError('Created groups error: ${failure.message}'));
            },
            (createdGroups) => emit(HomeLoaded(
              joinedGroups: joinedGroups,
              createdGroups: createdGroups,
            )),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in HomeBloc: $e\n$stackTrace');
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddAddress(AddGroupAddressEvent event, Emitter<HomeState> emit) async {
    // Handled by backend indexer, ignore.
  }
}
