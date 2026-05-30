import 'package:takturns_flutter_app/features/groups/domain/entities/cycle_progress.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/member.dart';

abstract class GroupRepository {
  // Factory interactions
  Future<String> createGroup({
    required int minGrade,
    required BigInt contributionAmount,
    required BigInt cycleDuration,
    required int maxMembers,
    required String token,
  });

  Future<BigInt> getCollateralAmount({
    required BigInt contribution,
    required int minGrade,
  });

  // Group interactions
  Future<void> approveUsdc({
    required String spender,
    required BigInt amount,
  });

  Future<void> joinGroup(String groupAddress);
  Future<void> startGroup(String groupAddress);
  Future<void> contribute(String groupAddress);
  Future<void> flagDefaulter({
    required String groupAddress,
    required String memberAddress,
  });
  Future<void> castVote({required String groupAddress, required int vote});
  Future<void> resolveVote(String groupAddress);

  // Queries
  Future<Group> getGroupDetails(String groupAddress);
  Future<CycleProgress> getCycleProgress(String groupAddress);
  Future<List<Member>> getMembers(String groupAddress);
  Future<bool> hasContributed({
    required String groupAddress,
    required String memberAddress,
  });
  Future<String> getCurrentRecipient(String groupAddress);
}
