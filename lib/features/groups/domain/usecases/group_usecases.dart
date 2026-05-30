import 'package:dartz/dartz.dart';
import 'package:takturns_flutter_app/core/usecases/usecase.dart'; // Adjust path to your base Usecase file
import 'package:takturns_flutter_app/core/errors/failures.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/cycle_progress.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/member.dart';
import 'package:takturns_flutter_app/features/groups/domain/repositories/group_repository.dart';

// ─── Create Group ────────────────────────────────────────────────────────────
class CreateGroup implements Usecase<String, CreateGroupParams> {
  final GroupRepository repo;
  CreateGroup(this.repo);

  @override
  Future<Either<Failure, String>> call(CreateGroupParams params) {
    return repo.createGroup(
      minGrade: params.minGrade,
      contributionAmount: params.contributionAmount,
      cycleDuration: params.cycleDuration,
      maxMembers: params.maxMembers,
      token: params.token,
    );
  }
}

class CreateGroupParams {
  final int minGrade;
  final BigInt contributionAmount;
  final BigInt cycleDuration;
  final int maxMembers;
  final String token;

  const CreateGroupParams({
    required this.minGrade,
    required this.contributionAmount,
    required this.cycleDuration,
    required this.maxMembers,
    required this.token,
  });
}

// ─── Get Collateral Amount ───────────────────────────────────────────────────
class GetCollateralAmount implements Usecase<BigInt, GetCollateralParams> {
  final GroupRepository repo;
  GetCollateralAmount(this.repo);

  @override
  Future<Either<Failure, BigInt>> call(GetCollateralParams params) {
    return repo.getCollateralAmount(
      contribution: params.contribution,
      minGrade: params.minGrade,
    );
  }
}

class GetCollateralParams {
  final BigInt contribution;
  final int minGrade;

  const GetCollateralParams({required this.contribution, required this.minGrade});
}

// ─── Approve USDC ─────────────────────────────────────────────────────────────
class ApproveUsdc implements Usecase<void, ApproveUsdcParams> {
  final GroupRepository repo;
  ApproveUsdc(this.repo);

  @override
  Future<Either<Failure, void>> call(ApproveUsdcParams params) {
    return repo.approveUsdc(spender: params.spender, amount: params.amount);
  }
}

class ApproveUsdcParams {
  final String spender;
  final BigInt amount;

  const ApproveUsdcParams({required this.spender, required this.amount});
}

// ─── Join Group ──────────────────────────────────────────────────────────────
class JoinGroup implements Usecase<void, String> {
  final GroupRepository repo;
  JoinGroup(this.repo);

  @override
  Future<Either<Failure, void>> call(String groupAddress) => repo.joinGroup(groupAddress);
}

// ─── Start Group ─────────────────────────────────────────────────────────────
class StartGroup implements Usecase<void, String> {
  final GroupRepository repo;
  StartGroup(this.repo);

  @override
  Future<Either<Failure, void>> call(String groupAddress) => repo.startGroup(groupAddress);
}

// ─── Contribute ──────────────────────────────────────────────────────────────
class Contribute implements Usecase<void, String> {
  final GroupRepository repo;
  Contribute(this.repo);

  @override
  Future<Either<Failure, void>> call(String groupAddress) => repo.contribute(groupAddress);
}

// ─── Flag Defaulter ──────────────────────────────────────────────────────────
class FlagDefaulter implements Usecase<void, FlagDefaulterParams> {
  final GroupRepository repo;
  FlagDefaulter(this.repo);

  @override
  Future<Either<Failure, void>> call(FlagDefaulterParams params) {
    return repo.flagDefaulter(
      groupAddress: params.groupAddress,
      memberAddress: params.memberAddress,
    );
  }
}

class FlagDefaulterParams {
  final String groupAddress;
  final String memberAddress;

  const FlagDefaulterParams({required this.groupAddress, required this.memberAddress});
}

// ─── Cast Vote ───────────────────────────────────────────────────────────────
class CastVote implements Usecase<void, CastVoteParams> {
  final GroupRepository repo;
  CastVote(this.repo);

  @override
  Future<Either<Failure, void>> call(CastVoteParams params) {
    return repo.castVote(groupAddress: params.groupAddress, vote: params.vote);
  }
}

class CastVoteParams {
  final String groupAddress;
  final int vote;

  const CastVoteParams({required this.groupAddress, required this.vote});
}

// ─── Resolve Vote ────────────────────────────────────────────────────────────
class ResolveVote implements Usecase<void, String> {
  final GroupRepository repo;
  ResolveVote(this.repo);

  @override
  Future<Either<Failure, void>> call(String groupAddress) => repo.resolveVote(groupAddress);
}

// ─── Get Group Details ───────────────────────────────────────────────────────
class GetGroupDetails implements Usecase<Group, String> {
  final GroupRepository repo;
  GetGroupDetails(this.repo);

  @override
  Future<Either<Failure, Group>> call(String groupAddress) => repo.getGroupDetails(groupAddress);
}

// ─── Get Cycle Progress ──────────────────────────────────────────────────────
class GetCycleProgress implements Usecase<CycleProgress, String> {
  final GroupRepository repo;
  GetCycleProgress(this.repo);

  @override
  Future<Either<Failure, CycleProgress>> call(String groupAddress) => repo.getCycleProgress(groupAddress);
}

// ─── Get Members ─────────────────────────────────────────────────────────────
class GetMembers implements Usecase<List<Member>, String> {
  final GroupRepository repo;
  GetMembers(this.repo);

  @override
  Future<Either<Failure, List<Member>>> call(String groupAddress) => repo.getMembers(groupAddress);
}

// ─── Has Contributed ─────────────────────────────────────────────────────────
class HasContributed implements Usecase<bool, HasContributedParams> {
  final GroupRepository repo;
  HasContributed(this.repo);

  @override
  Future<Either<Failure, bool>> call(HasContributedParams params) {
    return repo.hasContributed(
      groupAddress: params.groupAddress,
      memberAddress: params.memberAddress,
    );
  }
}

class HasContributedParams {
  final String groupAddress;
  final String memberAddress;

  const HasContributedParams({required this.groupAddress, required this.memberAddress});
}