import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/core/utils/extensions.dart';
import 'package:takturns_flutter_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:takturns_flutter_app/features/wallet/presentation/bloc/wallet_bloc.dart';

import '../../../wallet/presentation/bloc/wallet_event.dart';
import '../../../wallet/presentation/bloc/wallet_state.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadGroupsEvent());
    context.read<WalletBloc>().add(RefreshBalanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TakTurns Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<WalletBloc>().add(DisconnectWalletEvent());
              context.goNamed('wallet');
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, walletState) {
          if (walletState is! WalletConnected) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const LoadGroupsEvent());
              context.read<WalletBloc>().add(RefreshBalanceEvent());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWalletCard(context, walletState),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.pushNamed('create-group').then((_) {
                          if (!context.mounted) return;
                          context.read<HomeBloc>().add(const LoadGroupsEvent());
                        }),
                        icon: const Icon(Icons.add),
                        label: const Text('Create'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.pushNamed('join-group').then((_) {
                          if (!context.mounted) return;
                          context.read<HomeBloc>().add(const LoadGroupsEvent());
                        }),
                        icon: const Icon(Icons.group_add),
                        label: const Text('Join'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('My Groups', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, homeState) {
                    if (homeState is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (homeState is HomeError) {
                      return Text('Error: ${homeState.message}', style: const TextStyle(color: AppColors.error));
                    } else if (homeState is HomeLoaded) {
                      if (homeState.groups.isEmpty) {
                        return const Text('You have not joined any groups yet.', style: TextStyle(color: AppColors.textSecondary));
                      }
                      return Column(
                        children: homeState.groups.map((group) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Group: ${group.address.truncated}'),
                              subtitle: Text('${group.contributionAmount.toUsdc()} • ${group.cycleDuration.toInt().cycleDurationLabel}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.pushNamed('group-detail', pathParameters: {'address': group.address}).then((_) {
                                if (!context.mounted) return;
                                context.read<HomeBloc>().add(const LoadGroupsEvent());
                              }),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletConnected state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Wallet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Grade ${state.wallet.displayGrade}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(state.wallet.address.truncated, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 24),
          Text('USDC Balance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          Text(state.wallet.usdcBalance.toUsdc(), style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
