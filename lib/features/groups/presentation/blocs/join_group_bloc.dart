import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

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

// ─── States ───────────────────────────────────────────────────────────────────

abstract class JoinGroupState extends Equatable {
  const JoinGroupState();
  @override List<Object?> get props => [];
}

class JoinGroupInitial extends JoinGroupState {}
class JoinGroupLoadingPreview extends JoinGroupState {}
class JoinGroupPreviewLoaded extends JoinGroupState {
  final Group group;
  final BigInt collateral;
  const JoinGroupPreviewLoaded({required this.group, required this.collateral});
  @override List<Object?> get props => [group, collateral];
}
class JoinGroupJoining extends JoinGroupState {
  final String message;
  const JoinGroupJoining(this.message);
  @override List<Object?> get props => [message];
}
class JoinGroupSuccess extends JoinGroupState {
  final String groupAddress;
  const JoinGroupSuccess(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}
class JoinGroupError extends JoinGroupState {
  final String message;
  const JoinGroupError(this.message);
  @override List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

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
    try {
      final group = await getGroupDetails(event.groupAddress);
      final collateral = await getCollateralAmount(
        contribution: group.contributionAmount,
        minGrade: group.minGrade,
      );
      emit(JoinGroupPreviewLoaded(group: group, collateral: collateral));
    } catch (e) {
      emit(JoinGroupError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onConfirmJoin(
    ConfirmJoinEvent event,
    Emitter<JoinGroupState> emit,
  ) async {
    final preview = state as JoinGroupPreviewLoaded;
    try {
      emit(const JoinGroupJoining('Approving USDC collateral...'));
      await approveUsdc(
        spender: event.groupAddress,
        amount: preview.collateral,
      );
      emit(const JoinGroupJoining('Joining group...'));
      await joinGroup(event.groupAddress);
      emit(JoinGroupSuccess(event.groupAddress));
    } catch (e) {
      emit(JoinGroupError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
