import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:takturns_flutter_app/core/constants/app_assets.dart';
import 'package:takturns_flutter_app/core/di/injection_container.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/core/utils/mask_wallet.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_bloc.dart';

import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  late ReownAppKitModal _appKit;

  @override
  void initState() {
    super.initState();
    _appKit = sl<ReownAppKitModal>();
    _appKit.addListener(_onAppKitChange);
  }

  @override
  void dispose() {
    _appKit.removeListener(_onAppKitChange);
    super.dispose();
  }

  void _onAppKitChange() {
    // When the session changes (connected/disconnected), tell the bloc to check
    context.read<WalletBloc>().add(CheckStoredWalletEvent());
  }

  @override
  Widget build(BuildContext context) {
    final Color badgeBg = AppColors.secondaryContainer;
    final Color badgeText = AppColors.onSecondaryContainer;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: BlocConsumer<WalletBloc, WalletState>(
              listener: (context, state) {
                if (state is WalletError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                  AppAssets.metamask,
                                width: 56,
                              )
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: state is WalletConnected ? AppColors.success.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: state is WalletConnected ? AppColors.success : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state is WalletConnected ? 'Wallet Connected' : 'Wallet Disconnected',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: state is WalletConnected ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      state is WalletConnected ? maskWalletAddress(state.wallet.address) : 'Connect Web3 Wallet',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // AppKit standard connection button
                    Center(
                      child: AppKitModalConnectButton(
                        appKit: _appKit,
                      ),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state is WalletConnected ? AppColors.primary : Colors.grey,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      onPressed: () {
                        if(state is WalletConnected) {
                          context.push('/home');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Proceed to Dashboard'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (state is WalletConnected)
                      TextButton(
                        onPressed: () {
                          _appKit.disconnect();
                          context.read<WalletBloc>().add(DisconnectWalletEvent());
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                        ),
                        child: const Text(
                          'Disconnect',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
