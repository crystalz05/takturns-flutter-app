import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();
  @override List<Object?> get props => [];
}

class SubmitCreateGroupEvent extends CreateGroupEvent {
  final int minGrade;
  final double contributionAmountUsdc;
  final int cycleDurationDays;
  final int maxMembers;
  const SubmitCreateGroupEvent({
    required this.minGrade,
    required this.contributionAmountUsdc,
    required this.cycleDurationDays,
    required this.maxMembers,
  });
  @override
  List<Object?> get props => [minGrade, contributionAmountUsdc, cycleDurationDays, maxMembers];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class CreateGroupState extends Equatable {
  const CreateGroupState();
  @override List<Object?> get props => [];
}

class CreateGroupInitial extends CreateGroupState {}
class CreateGroupLoading extends CreateGroupState {
  final String message;
  const CreateGroupLoading(this.message);
  @override List<Object?> get props => [message];
}
class CreateGroupSuccess extends CreateGroupState {
  final String groupAddress;
  const CreateGroupSuccess(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}
class CreateGroupError extends CreateGroupState {
  final String message;
  const CreateGroupError(this.message);
  @override List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final CreateGroup createGroup;
  final ApproveUsdc approveUsdc;
  final WalletRepository walletRepository;

  CreateGroupBloc({
    required this.createGroup,
    required this.approveUsdc,
    required this.walletRepository,
  }) : super(CreateGroupInitial()) {
    on<SubmitCreateGroupEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitCreateGroupEvent event,
    Emitter<CreateGroupState> emit,
  ) async {
    emit(const CreateGroupLoading('Deploying group contract...'));
    try {
      final contributionRaw = BigInt.from(
        (event.contributionAmountUsdc * 1e6).round(),
      );
      final cycleDurationSeconds = BigInt.from(event.cycleDurationDays * 86400);

      final groupAddress = await createGroup(
        minGrade: event.minGrade,
        contributionAmount: contributionRaw,
        cycleDuration: cycleDurationSeconds,
        maxMembers: event.maxMembers,
        token: AppConstants.usdcAddress,
      );

      emit(CreateGroupSuccess(groupAddress));
    } catch (e) {
      emit(CreateGroupError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
