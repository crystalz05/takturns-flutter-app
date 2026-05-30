import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletFailure extends Failure {
  const WalletFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ContractFailure extends Failure {
  const ContractFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class BlacklistedFailure extends Failure {
  const BlacklistedFailure(super.message);
}

/// A specific failure fallback for unexpected web3/EVM provider errors
class BlockchainFailure extends Failure {
  const BlockchainFailure(super.message);
}