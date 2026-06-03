import 'package:dartz/dartz.dart';
import 'package:takturns_flutter_app/core/errors/failures.dart';
import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';
import 'package:takturns_flutter_app/features/groups/domain/repositories/group_repository.dart';

class GetUserGroups {
  final GroupRepository repository;

  GetUserGroups(this.repository);

  Future<Either<Failure, List<Group>>> call(String walletAddress) async {
    return await repository.getUserGroups(walletAddress);
  }
}
