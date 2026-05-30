import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/cycle_progress.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/member.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';

import 'group_detail_event.dart';
import 'group_detail_state.dart';

// ... Events and States remain the same ...

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GetGroupDetails getGroupDetails;
  final GetCycleProgress getCycleProgress;
  final GetMembers getMembers;
  final HasContributed hasContributed;
  final FlagDefaulter flagDefaulter;
  final CastVote castVote;
  final ResolveVote resolveVote;
  final StartGroup startGroup;
  final Contribute contribute;
  final WalletRepository walletRepository;

  GroupDetailBloc({
    required this.getGroupDetails,
    required this.getCycleProgress,
    required this.getMembers,
    required this.hasContributed,
    required this.flagDefaulter,
    required this.castVote,
    required this.resolveVote,
    required this.startGroup,
    required this.contribute,
    required this.walletRepository,
  }) : super(GroupDetailInitial()) {
    on<LoadGroupDetailEvent>(_onLoad);
    on<RefreshGroupDetailEvent>(_onRefresh);
    on<StartGroupEvent>(_onStartGroup);
    on<ContributeEvent>(_onContribute);
    on<FlagDefaulterEvent>(_onFlagDefaulter);
    on<CastVoteEvent>(_onCastVote);
    on<ResolveVoteEvent>(_onResolveVote);
  }

  /// Fetches group data structures and formats them sequentially using functional steps
  Future<GroupDetailLoaded?> _fetchAll(String address, Emitter<GroupDetailState> emit) async {
    final myAddress = walletRepository.currentAddress ?? '';

    final groupRes = await getGroupDetails(address);
    return await groupRes.fold(
          (failure) {
        emit(GroupDetailError(failure.message));
        return null;
      },
          (group) async {
        final progressRes = await getCycleProgress(address);
        return await progressRes.fold(
              (failure) {
            emit(GroupDetailError(failure.message));
            return null;
          },
              (progress) async {
            final membersRes = await getMembers(address);
            return await membersRes.fold(
                  (failure) {
                emit(GroupDetailError(failure.message));
                return null;
              },
                  (members) async {
                bool myContrib = false;
                if (myAddress.isNotEmpty && group.isActive) {
                  final contribRes = await hasContributed(
                    HasContributedParams(groupAddress: address, memberAddress: myAddress),
                  );
                  myContrib = contribRes.getOrElse(() => false);
                }

                return GroupDetailLoaded(
                  group: group,
                  cycleProgress: progress,
                  members: members,
                  myContributed: myContrib,
                  myAddress: myAddress,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onLoad(LoadGroupDetailEvent e, Emitter<GroupDetailState> emit) async {
    emit(GroupDetailLoading());
    final data = await _fetchAll(e.groupAddress, emit);
    if (data != null) emit(data);
  }

  Future<void> _onRefresh(RefreshGroupDetailEvent e, Emitter<GroupDetailState> emit) async {
    final data = await _fetchAll(e.groupAddress, emit);
    if (data != null) emit(data);
  }

  Future<void> _onStartGroup(StartGroupEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Starting group...', previousState: prev));

    final result = await startGroup(e.groupAddress);
    await result.fold(
          (failure) async => emit(GroupDetailError(failure.message)),
          (_) async {
        final data = await _fetchAll(e.groupAddress, emit);
        if (data != null) emit(GroupDetailTxSuccess(message: 'Group started!', data: data));
      },
    );
  }

  Future<void> _onContribute(ContributeEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Sending contribution...', previousState: prev));

    final result = await contribute(e.groupAddress);
    await result.fold(
          (failure) async => emit(GroupDetailError(failure.message)),
          (_) async {
        final data = await _fetchAll(e.groupAddress, emit);
        if (data != null) emit(GroupDetailTxSuccess(message: 'Contribution sent! 🎉', data: data));
      },
    );
  }

  Future<void> _onFlagDefaulter(FlagDefaulterEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Flagging defaulter...', previousState: prev));

    final result = await flagDefaulter(
      FlagDefaulterParams(groupAddress: e.groupAddress, memberAddress: e.memberAddress),
    );
    await result.fold(
          (failure) async => emit(GroupDetailError(failure.message)),
          (_) async {
        final data = await _fetchAll(e.groupAddress, emit);
        if (data != null) emit(GroupDetailTxSuccess(message: 'Defaulter flagged.', data: data));
      },
    );
  }

  Future<void> _onCastVote(CastVoteEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Casting vote...', previousState: prev));

    final result = await castVote(CastVoteParams(groupAddress: e.groupAddress, vote: e.vote));
    await result.fold(
          (failure) async => emit(GroupDetailError(failure.message)),
          (_) async {
        final data = await _fetchAll(e.groupAddress, emit);
        if (data != null) emit(GroupDetailTxSuccess(message: 'Vote cast!', data: data));
      },
    );
  }

  Future<void> _onResolveVote(ResolveVoteEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Resolving vote...', previousState: prev));

    final result = await resolveVote(e.groupAddress);
    await result.fold(
          (failure) async => emit(GroupDetailError(failure.message)),
          (_) async {
        final data = await _fetchAll(e.groupAddress, emit);
        if (data != null) emit(GroupDetailTxSuccess(message: 'Vote resolved!', data: data));
      },
    );
  }
}