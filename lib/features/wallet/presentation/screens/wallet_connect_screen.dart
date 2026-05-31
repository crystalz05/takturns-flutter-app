import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/constants/app_assets.dart';
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
  final _pkController = TextEditingController(text: "7ad85c6d7d3af578f92b17e016d37d54e09f1e2f216f0b536ce8d204841da2d3");

  @override
  void dispose() {
    _pkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Relying strictly on your AppColors mapping for component specific styling
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

                    // Profile Avatar stacked with Verification Badge
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
                          // Verification Badge Circle
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

                    // Connection Status Pill Bubble
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
                              state is WalletConnected ? 'WalletConnected' : 'Wallet Disconnected',
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

                    // Masked Address text presentation
                    Text(
                      state is WalletConnected ? maskWalletAddress(state.wallet.address) : 'Connect Wallet',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    const SizedBox(height: 32),

                    // Manual Connection Action Layer (Using styling rules from context)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                      ),
                      // 1. Disable interaction while connecting
                      onPressed: state is WalletConnecting
                          ? null
                          : () {
                        // Your wallet connection logic here
                      },
                      // 2. Dynamic icon swap
                      icon: state is WalletConnecting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      )
                          : const Icon(Icons.lock_open_outlined, size: 18),
                      // 3. Dynamic label update
                      label: Text(
                        state is WalletConnecting ? 'Connecting...' : 'Connect to Wallet',
                      ),
                    ),
                    const SizedBox(height: 12),


                    // Elegant Native "OR" Divider Layout
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Plain Input Field Label Descriptor
                    Text(
                      'Private Key',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Configured Input Field utilizing your InputDecorationTheme global settings
                    TextField(
                      controller: _pkController,
                      obscureText: true,
                      style: TextStyle(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Enter your private key',
                        prefixIcon: Icon(Icons.key_outlined, color: AppColors.outline),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Manual Connection Action Layer (Using styling rules from context)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                      ),
                      // 1. Disable the button by passing null if the state is connecting
                      onPressed: state is WalletConnecting
                          ? null
                          : () {
                        final pk = _pkController.text.trim();
                        context.read<WalletBloc>().add(ConnectWalletEvent(pk));
                      },
                      // 2. Swap the icon for a small loading spinner when connecting
                      icon: state is WalletConnecting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          // Inherits the foreground color (white/grey) automatically
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      )
                          : const Icon(Icons.lock_open_outlined, size: 18),
                      // 3. Optional: Update the label text dynamically to give user feedback
                      label: Text(
                        state is WalletConnecting ? 'Connecting...' : 'Connect Manually',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Forward to Dashboard Action Core (AppColors.primary)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state is WalletConnected ? AppColors.primary : Colors.grey,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      onPressed: () {
                        // if(state is WalletConnected) () =>
                            context.push('/home');
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

                    // Terminal Disconnect Text Trigger
                    TextButton(
                      onPressed: () {
                        if(state is WalletConnected) {
                          context.read<WalletBloc>().add(DisconnectWalletEvent());
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                      ),
                      child: const Text(
                        'Disconnect Wallet',
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

