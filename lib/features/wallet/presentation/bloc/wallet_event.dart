import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class CheckStoredWalletEvent extends WalletEvent {}

class ConnectWalletEvent extends WalletEvent {
  final String privateKey;
  const ConnectWalletEvent(this.privateKey);
  @override
  List<Object?> get props => [privateKey];
}

class DisconnectWalletEvent extends WalletEvent {}

class RefreshBalanceEvent extends WalletEvent {}