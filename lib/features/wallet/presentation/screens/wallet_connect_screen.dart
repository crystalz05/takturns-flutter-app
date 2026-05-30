import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletChecking || state is WalletConnecting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 80, color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to TakTurns',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Onchain Ajo on Arbitrum Sepolia',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _pkController,
                    decoration: const InputDecoration(
                      labelText: 'Private Key',
                      hintText: 'Enter your testnet private key',
                      prefixIcon: Icon(Icons.key, color: AppColors.textSecondary),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final pk = _pkController.text.trim();
                      if (pk.isEmpty) return;
                      context.read<WalletBloc>().add(ConnectWalletEvent(pk));
                    },
                    child: const Text('Connect Wallet'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
