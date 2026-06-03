import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cycle_progress.dart';
import '../entities/group.dart';
import '../entities/member.dart';

abstract class GroupRepository {
  Future<Either<Failure, String>> createGroup({
    required int minGrade,
    required BigInt contributionAmount,
    required BigInt cycleDuration,
    required int maxMembers,
    required String token,
  });
  Future<Either<Failure, BigInt>> getCollateralAmount({required BigInt contribution, required int minGrade});
  Future<Either<Failure, void>> approveUsdc({required String spender, required BigInt amount});
  Future<Either<Failure, void>> joinGroup(String groupAddress);
  Future<Either<Failure, void>> startGroup(String groupAddress);
  Future<Either<Failure, void>> contribute(String groupAddress);
  Future<Either<Failure, void>> flagDefaulter({required String groupAddress, required String memberAddress});
  Future<Either<Failure, void>> castVote({required String groupAddress, required int vote});
  Future<Either<Failure, void>> resolveVote(String groupAddress);
  Future<Either<Failure, Group>> getGroupDetails(String groupAddress);
  Future<Either<Failure, CycleProgress>> getCycleProgress(String groupAddress);
  Future<Either<Failure, List<Member>>> getMembers(String groupAddress);
  Future<Either<Failure, List<Group>>> getUserGroups(String walletAddress);
  Future<Either<Failure, List<Group>>> getCreatedGroups(String walletAddress);
  Future<Either<Failure, bool>> hasContributed({required String groupAddress, required String memberAddress});
  Future<Either<Failure, String>> getCurrentRecipient(String groupAddress);
}