import 'package:equatable/equatable.dart';

import '../../domain/entities/wallet_info.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}
class WalletChecking extends WalletState {}
class WalletConnecting extends WalletState {}

class WalletConnected extends WalletState {
  final WalletInfo wallet;
  const WalletConnected({required this.wallet});
  @override
  List<Object?> get props => [wallet];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object?> get props => [message];
}

class WalletDisconnected extends WalletState {}
