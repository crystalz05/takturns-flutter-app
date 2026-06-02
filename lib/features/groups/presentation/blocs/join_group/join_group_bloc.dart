import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';

import 'join_group_event.dart';
import 'join_group_state.dart';

// ... Events and States remain the same ...

class JoinGroupBloc extends Bloc<JoinGroupEvent, JoinGroupState> {
  final GetGroupDetails getGroupDetails;
  final ApproveUsdc approveUsdc;
  final JoinGroup joinGroup;
  final GetCollateralAmount getCollateralAmount;

  JoinGroupBloc({
    required this.getGroupDetails,
    required this.approveUsdc,
    required this.joinGroup,
    required this.getCollateralAmount,
  }) : super(JoinGroupInitial()) {
    on<PreviewGroupEvent>(_onPreview);
    on<ConfirmJoinEvent>(_onConfirmJoin);
  }

  Future<void> _onPreview(
      PreviewGroupEvent event,
      Emitter<JoinGroupState> emit,
      ) async {
    emit(JoinGroupLoadingPreview());

    final groupResult = await getGroupDetails(event.groupAddress);
    await groupResult.fold(
          (failure) async {
            log("failed ${failure.message}", name: "join group bloc");
            emit(JoinGroupError(failure.message));
          },
          (group) async {
        final collateralResult = await getCollateralAmount(
          GetCollateralParams(contribution: group.contributionAmount, minGrade: group.minGrade),
        );
        collateralResult.fold(
              (failure) => emit(JoinGroupError(failure.message)),
              (collateral) => emit(JoinGroupPreviewLoaded(group: group, collateral: collateral)),
        );
      },
    );
  }

  Future<void> _onConfirmJoin(
      ConfirmJoinEvent event,
      Emitter<JoinGroupState> emit,
      ) async {
    final preview = state as JoinGroupPreviewLoaded;
    emit(const JoinGroupJoining('Approving USDC collateral...'));

    final approveResult = await approveUsdc(
      ApproveUsdcParams(spender: event.groupAddress, amount: preview.collateral),
    );

    await approveResult.fold(
          (failure) async => emit(JoinGroupError(failure.message)),
          (_) async {
        emit(const JoinGroupJoining('Joining group...'));
        final joinResult = await joinGroup(event.groupAddress);
        joinResult.fold(
              (failure) => emit(JoinGroupError(failure.message)),
              (_) => emit(JoinGroupSuccess(event.groupAddress)),
        );
      },
    );
  }
}