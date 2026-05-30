import 'package:takturns_flutter_app/features/groups/domain/entities/cycle_progress.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/member.dart';
import 'package:takturns_flutter_app/features/groups/domain/repositories/group_repository.dart';

class CreateGroup {
  final GroupRepository repo;
  CreateGroup(this.repo);
  Future<String> call({
    required int minGrade,
    required BigInt contributionAmount,
    required BigInt cycleDuration,
    required int maxMembers,
    required String token,
  }) => repo.createGroup(
    minGrade: minGrade,
    contributionAmount: contributionAmount,
    cycleDuration: cycleDuration,
    maxMembers: maxMembers,
    token: token,
  );
}

class GetCollateralAmount {
  final GroupRepository repo;
  GetCollateralAmount(this.repo);
  Future<BigInt> call({required BigInt contribution, required int minGrade}) =>
      repo.getCollateralAmount(contribution: contribution, minGrade: minGrade);
}

class ApproveUsdc {
  final GroupRepository repo;
  ApproveUsdc(this.repo);
  Future<void> call({required String spender, required BigInt amount}) =>
      repo.approveUsdc(spender: spender, amount: amount);
}

class JoinGroup {
  final GroupRepository repo;
  JoinGroup(this.repo);
  Future<void> call(String groupAddress) => repo.joinGroup(groupAddress);
}

class StartGroup {
  final GroupRepository repo;
  StartGroup(this.repo);
  Future<void> call(String groupAddress) => repo.startGroup(groupAddress);
}

class Contribute {
  final GroupRepository repo;
  Contribute(this.repo);
  Future<void> call(String groupAddress) => repo.contribute(groupAddress);
}

class FlagDefaulter {
  final GroupRepository repo;
  FlagDefaulter(this.repo);
  Future<void> call({
    required String groupAddress,
    required String memberAddress,
  }) => repo.flagDefaulter(groupAddress: groupAddress, memberAddress: memberAddress);
}

class CastVote {
  final GroupRepository repo;
  CastVote(this.repo);
  Future<void> call({required String groupAddress, required int vote}) =>
      repo.castVote(groupAddress: groupAddress, vote: vote);
}

class ResolveVote {
  final GroupRepository repo;
  ResolveVote(this.repo);
  Future<void> call(String groupAddress) => repo.resolveVote(groupAddress);
}

class GetGroupDetails {
  final GroupRepository repo;
  GetGroupDetails(this.repo);
  Future<Group> call(String groupAddress) => repo.getGroupDetails(groupAddress);
}

class GetCycleProgress {
  final GroupRepository repo;
  GetCycleProgress(this.repo);
  Future<CycleProgress> call(String groupAddress) =>
      repo.getCycleProgress(groupAddress);
}

class GetMembers {
  final GroupRepository repo;
  GetMembers(this.repo);
  Future<List<Member>> call(String groupAddress) => repo.getMembers(groupAddress);
}

class HasContributed {
  final GroupRepository repo;
  HasContributed(this.repo);
  Future<bool> call({
    required String groupAddress,
    required String memberAddress,
  }) => repo.hasContributed(
    groupAddress: groupAddress,
    memberAddress: memberAddress,
  );
}
