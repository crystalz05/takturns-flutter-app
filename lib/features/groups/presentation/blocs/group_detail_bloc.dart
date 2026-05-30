import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/cycle_progress.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/member.dart';
import 'package:takturns_flutter_app/features/groups/domain/usecases/group_usecases.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();
  @override List<Object?> get props => [];
}

class LoadGroupDetailEvent extends GroupDetailEvent {
  final String groupAddress;
  const LoadGroupDetailEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class RefreshGroupDetailEvent extends GroupDetailEvent {
  final String groupAddress;
  const RefreshGroupDetailEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class StartGroupEvent extends GroupDetailEvent {
  final String groupAddress;
  const StartGroupEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class ContributeEvent extends GroupDetailEvent {
  final String groupAddress;
  const ContributeEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

class FlagDefaulterEvent extends GroupDetailEvent {
  final String groupAddress;
  final String memberAddress;
  const FlagDefaulterEvent({required this.groupAddress, required this.memberAddress});
  @override List<Object?> get props => [groupAddress, memberAddress];
}

class CastVoteEvent extends GroupDetailEvent {
  final String groupAddress;
  final int vote;
  const CastVoteEvent({required this.groupAddress, required this.vote});
  @override List<Object?> get props => [groupAddress, vote];
}

class ResolveVoteEvent extends GroupDetailEvent {
  final String groupAddress;
  const ResolveVoteEvent(this.groupAddress);
  @override List<Object?> get props => [groupAddress];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class GroupDetailState extends Equatable {
  const GroupDetailState();
  @override List<Object?> get props => [];
}

class GroupDetailInitial extends GroupDetailState {}
class GroupDetailLoading extends GroupDetailState {}

class GroupDetailLoaded extends GroupDetailState {
  final Group group;
  final CycleProgress cycleProgress;
  final List<Member> members;
  final bool myContributed;
  final String myAddress;

  const GroupDetailLoaded({
    required this.group,
    required this.cycleProgress,
    required this.members,
    required this.myContributed,
    required this.myAddress,
  });

  bool get isAdmin => group.admin.toLowerCase() == myAddress.toLowerCase();
  bool get isMyTurn =>
      group.currentRecipient.toLowerCase() == myAddress.toLowerCase();

  @override
  List<Object?> get props => [group, cycleProgress, members, myContributed, myAddress];
}

class GroupDetailTransacting extends GroupDetailState {
  final String message;
  final GroupDetailLoaded previousState;
  const GroupDetailTransacting({required this.message, required this.previousState});
  @override List<Object?> get props => [message];
}

class GroupDetailError extends GroupDetailState {
  final String message;
  const GroupDetailError(this.message);
  @override List<Object?> get props => [message];
}

class GroupDetailTxSuccess extends GroupDetailState {
  final String message;
  final GroupDetailLoaded data;
  const GroupDetailTxSuccess({required this.message, required this.data});
  @override List<Object?> get props => [message, data];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

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

  Future<GroupDetailLoaded?> _fetchAll(String address) async {
    final myAddress = walletRepository.currentAddress ?? '';
    final results = await Future.wait([
      getGroupDetails(address),
      getCycleProgress(address),
      getMembers(address),
    ]);
    final group = results[0] as Group;
    final progress = results[1] as CycleProgress;
    final members = results[2] as List<Member>;
    bool myContrib = false;
    if (myAddress.isNotEmpty && group.isActive) {
      try {
        myContrib = await hasContributed(
          groupAddress: address,
          memberAddress: myAddress,
        );
      } catch (_) {}
    }
    return GroupDetailLoaded(
      group: group,
      cycleProgress: progress,
      members: members,
      myContributed: myContrib,
      myAddress: myAddress,
    );
  }

  Future<void> _onLoad(LoadGroupDetailEvent e, Emitter<GroupDetailState> emit) async {
    emit(GroupDetailLoading());
    try {
      final data = await _fetchAll(e.groupAddress);
      if (data != null) emit(data);
    } catch (err) {
      emit(GroupDetailError(err.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(RefreshGroupDetailEvent e, Emitter<GroupDetailState> emit) async {
    try {
      final data = await _fetchAll(e.groupAddress);
      if (data != null) emit(data);
    } catch (err) {
      emit(GroupDetailError(err.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onStartGroup(StartGroupEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Starting group...', previousState: prev));
    try {
      await startGroup(e.groupAddress);
      final data = await _fetchAll(e.groupAddress);
      if (data != null) emit(GroupDetailTxSuccess(message: 'Group started!', data: data));
    } catch (err) {
      emit(GroupDetailError(err.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onContribute(ContributeEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Sending contribution...', previousState: prev));
    try {
      await contribute(e.groupAddress);
      final data = await _fetchAll(e.groupAddress);
      if (data != null) emit(GroupDetailTxSuccess(message: 'Contribution sent! 🎉', data: data));
    } catch (err) {
      emit(GroupDetailError(err.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFlagDefaulter(FlagDefaulterEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Flagging defaulter...', previousState: prev));
    try {
      await flagDefaulter(groupAddress: e.groupAddress, memberAddress: e.memberAddress);
      final data = await _fetchAll(e.groupAddress);
      if (data != null) emit(GroupDetailTxSuccess(message: 'Defaulter flagged.', data: data));
    } catch (err) {
      emit(GroupDetailError(err.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCastVote(CastVoteEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Casting vote...', previousState: prev));
    try {
      await castVote(groupAddress: e.groupAddress, vote: e.vote);
      final data = await _fetchAll(e.groupAddress);
      if (data != null) emit(GroupDetailTxSuccess(message: 'Vote cast!', data: data));
    } catch (err) {
      emit(GroupDetailError(err.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResolveVote(ResolveVoteEvent e, Emitter<GroupDetailState> emit) async {
    final prev = state as GroupDetailLoaded;
    emit(GroupDetailTransacting(message: 'Resolving vote...', previousState: prev));
    try {
      await resolveVote(e.groupAddress);
      final data = await _fetchAll(e.groupAddress);
      if (data != null) emit(GroupDetailTxSuccess(message: 'Vote resolved!', data: data));
    } catch (err) {
      emit(GroupDetailError(err.toString().replaceAll('Exception: ', '')));
    }
  }
}
