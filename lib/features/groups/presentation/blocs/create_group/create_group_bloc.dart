import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takturns_flutter_app/core/constants/app_constants.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';

import 'create_group_event.dart';
import 'create_group_state.dart';


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

    final contributionRaw = BigInt.from((event.contributionAmountUsdc * 1e6).round());
    final cycleDurationSeconds = BigInt.from(event.cycleDurationDays * 86400);

    final result = await createGroup(
      CreateGroupParams(
        minGrade: event.minGrade,
        contributionAmount: contributionRaw,
        cycleDuration: cycleDurationSeconds,
        maxMembers: event.maxMembers,
        token: AppConstants.usdcAddress,
      ),
    );

    result.fold(
          (failure) => emit(CreateGroupError(failure.message)),
          (groupAddress) => emit(CreateGroupSuccess(groupAddress)),
    );
  }
}