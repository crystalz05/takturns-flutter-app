abstract class Failure {
  final String message;
  const Failure(this.message);
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
