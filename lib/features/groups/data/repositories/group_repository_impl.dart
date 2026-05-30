import 'package:dartz/dartz.dart';
import 'package:web3dart/web3dart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cycle_progress.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/remote_data_source.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;
  final EthPrivateKey Function() _getCredentials;

  GroupRepositoryImpl(this._remoteDataSource, this._getCredentials);

  // ─── Functional Exception-to-Failure Safe Wrapper ─────────────────────────
  Future<Either<Failure, T>> _errorHandler<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();

      if (errorMsg.contains('user denied') || errorMsg.contains('rejected')) {
        return const Left(WalletFailure("Transaction signature rejected by user."));
      } else if (errorMsg.contains('execution reverted') || errorMsg.contains('revert')) {
        return Left(ContractFailure("Smart contract execution reverted: $e"));
      } else if (errorMsg.contains('network') || errorMsg.contains('http')) {
        return const Left(NetworkFailure("Unable to connect to RPC node provider. Check connection."));
      }

      return Left(ContractFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createGroup({
    required int minGrade,
    required BigInt contributionAmount,
    required BigInt cycleDuration,
    required int maxMembers,
    required String token,
  }) {
    return _errorHandler(() => _remoteDataSource.createGroup(
      minGrade: minGrade,
      contributionAmount: contributionAmount,
      cycleDuration: cycleDuration,
      maxMembers: maxMembers,
      token: token,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, BigInt>> getCollateralAmount({
    required BigInt contribution,
    required int minGrade,
  }) {
    return _errorHandler(() => _remoteDataSource.getCollateralAmount(
      contribution: contribution,
      minGrade: minGrade,
    ));
  }

  @override
  Future<Either<Failure, void>> approveUsdc({
    required String spender,
    required BigInt amount,
  }) {
    return _errorHandler(() => _remoteDataSource.approveUsdc(
      spender: spender,
      amount: amount,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, void>> joinGroup(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.joinGroup(
      groupAddress: groupAddress,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, void>> startGroup(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.startGroup(
      groupAddress: groupAddress,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, void>> contribute(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.contribute(
      groupAddress: groupAddress,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, void>> flagDefaulter({
    required String groupAddress,
    required String memberAddress,
  }) {
    return _errorHandler(() => _remoteDataSource.flagDefaulter(
      groupAddress: groupAddress,
      memberAddress: memberAddress,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, void>> castVote({required String groupAddress, required int vote}) {
    return _errorHandler(() => _remoteDataSource.castVote(
      groupAddress: groupAddress,
      vote: vote,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, void>> resolveVote(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.resolveVote(
      groupAddress: groupAddress,
      credentials: _getCredentials(),
    ));
  }

  @override
  Future<Either<Failure, Group>> getGroupDetails(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.getGroupDetails(groupAddress));
  }

  @override
  Future<Either<Failure, CycleProgress>> getCycleProgress(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.getCycleProgress(groupAddress));
  }

  @override
  Future<Either<Failure, List<Member>>> getMembers(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.getMembers(groupAddress));
  }

  @override
  Future<Either<Failure, bool>> hasContributed({
    required String groupAddress,
    required String memberAddress,
  }) {
    return _errorHandler(() => _remoteDataSource.hasContributed(
      groupAddress: groupAddress,
      memberAddress: memberAddress,
    ));
  }

  @override
  Future<Either<Failure, String>> getCurrentRecipient(String groupAddress) {
    return _errorHandler(() => _remoteDataSource.getCurrentRecipient(groupAddress));
  }
}