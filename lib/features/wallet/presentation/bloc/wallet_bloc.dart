import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takturns_flutter_app/features/wallet/domain/entities/wallet_info.dart';
import 'package:takturns_flutter_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:takturns_flutter_app/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc({
    required WalletRepository walletRepository
  }) : _walletRepository = walletRepository,
        super(WalletInitial()) {
    on<CheckStoredWalletEvent>(_onCheckStored);
    on<ConnectWalletEvent>(_onConnect);
    on<DisconnectWalletEvent>(_onDisconnect);
    on<RefreshBalanceEvent>(_onRefreshBalance);
  }

  Future<void> _onCheckStored(
      CheckStoredWalletEvent event,
      Emitter<WalletState> emit,
      ) async {
    emit(WalletChecking());
    try {
      final result = await _walletRepository.getStoredWallet();
      if(result.isRight()){
        final wallet = result.getOrElse(() => null);
        if (wallet != null) {
          emit(WalletConnected(wallet: wallet));
        } else {
          emit(WalletDisconnected());
        }
      }else{
        emit(WalletDisconnected());
      }
    } catch (e) {
      emit(WalletDisconnected());
    }
  }

  Future<void> _onConnect(
      ConnectWalletEvent event,
      Emitter<WalletState> emit,
      ) async {
    emit(WalletConnecting());
    try {
      final result = await _walletRepository.connectWallet(event.privateKey);
      if(result.isRight()){
        final wallet = result.getOrElse(() => throw Exception("Failed to connect wallet"));
        emit(WalletConnected(wallet: wallet));
      }else{
        emit(WalletDisconnected());
      }
    } catch (e) {
      emit(WalletError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDisconnect(
      DisconnectWalletEvent event,
      Emitter<WalletState> emit,
      ) async {
    final result = await _walletRepository.disconnect();
    if(result.isRight()){
      emit(WalletDisconnected());
    }
  }

  Future<void> _onRefreshBalance(
      RefreshBalanceEvent event,
      Emitter<WalletState> emit,
      ) async {
    if (state is WalletConnected) {
      final current = (state as WalletConnected).wallet;
      try {

        final result = await _walletRepository.getUsdcBalance(current.address);
        if(result.isRight()){
          final balance = result.getOrElse(() => throw Exception("Failed to get USDC balance"));
          emit(WalletConnected(wallet: WalletInfo(
              address: current.address,
              usdcBalance: balance,
              grade: current.grade,
              consecutiveCompletions: current.consecutiveCompletions,
              isBlacklisted: current.isBlacklisted)
          ));
        }
      } catch (_) {}
    }
  }
}
