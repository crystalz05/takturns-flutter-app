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
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        if (walletState is! WalletConnected) return const Scaffold(body: SizedBox.shrink());

        return Scaffold(
          backgroundColor: AppColors.background,
          // Custom Top Header matching Design Profile
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 28),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'GRADE: ${walletState.wallet.displayGrade}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  walletState.wallet.address.truncated,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: AppColors.error),
                onPressed: () {
                  context.read<WalletBloc>().add(DisconnectWalletEvent());
                  context.goNamed('wallet');
                },
              ),
            ],
          ),

          // Primary View Layout Engine
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<HomeBloc>().add(const LoadGroupsEvent());
              context.read<WalletBloc>().add(RefreshBalanceEvent());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Balance Metric Display Card
                _buildTotalBalanceCard(context, walletState),
                const SizedBox(height: 20),

                // 2. Twin Interactive Action Gateways (Create vs Join)
                _buildActionButtons(context),
                const SizedBox(height: 32),

                // 3. Dynamic Interactive Group Lists
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Groups',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildGroupsSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widget Component Assembly Blocks ---

  Widget _buildTotalBalanceCard(BuildContext context, WalletConnected state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      state.wallet.usdcBalance.toUsdc(), // e.g., $1,250.00
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'USDC',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance, color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Create New Group Tile (Solid Deep Green Accent)
        Expanded(
          child: SizedBox(
            height: 110,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => context.pushNamed('create-group').then((_) {
                if (!context.mounted) return;
                context.read<HomeBloc>().add(const LoadGroupsEvent());
              }),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle, size: 28),
                  SizedBox(height: 10),
                  Text(
                    'Create New\nGroup',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Join Existing Group Tile (Light Subtle Surface Container Tint)
        Expanded(
          child: SizedBox(
            height: 110,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: AppColors.onSurface,
                side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => context.pushNamed('join-group').then((_) {
                if (!context.mounted) return;
                context.read<HomeBloc>().add(const LoadGroupsEvent());
              }),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add_alt_1, size: 28, color: AppColors.onSurface),
                  SizedBox(height: 10),
                  Text(
                    'Join Existing\nGroup',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsSection(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        if (homeState is HomeLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
        } else if (homeState is HomeError) {
          return Text('Error: ${homeState.message}', style: const TextStyle(color: AppColors.error));
        } else if (homeState is HomeLoaded) {
          if (homeState.groups.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('You have not joined any groups yet.', style: TextStyle(color: AppColors.outline)),
            );
          }
          return Column(
            children: homeState.groups.map((group) {
              final Color badgeBg;
              final Color badgeFg;
              if (group.isActive) {
                badgeBg = AppColors.secondaryContainer;
                badgeFg = AppColors.onSecondaryContainer;
              } else if (group.isPending) {
                badgeBg = AppColors.surfaceContainer;
                badgeFg = AppColors.outline;
              } else if (group.isCompleted) {
                badgeBg = AppColors.primary;
                badgeFg = AppColors.onPrimary;
              } else {
                badgeBg = AppColors.errorContainer;
                badgeFg = AppColors.error;
              } 

              // Build deadline / status line
              final String statusLine;
              if (group.isActive && group.cycleDeadline > 0) {
                statusLine = 'Deadline: ${group.cycleDeadline.toDeadlineStr}';
              } else if (group.isPending) {
                statusLine = 'Waiting for members (${group.members.length}/${group.maxMembers})';
              } else {
                statusLine = group.state.name[0].toUpperCase() + group.state.name.substring(1);
              }

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                color: AppColors.surfaceContainerLowest,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.pushNamed('group-detail', pathParameters: {'address': group.address}).then((_) {
                    if (!context.mounted) return;
                    context.read<HomeBloc>().add(const LoadGroupsEvent());
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Member count fraction
                        Text(
                          '${group.members.length}/${group.maxMembers}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Group info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.address.truncated,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${group.contributionAmount.toUsdc()} USDC • ${group.cycleDuration.toInt().cycleDurationLabel}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    group.isActive ? Icons.timer_outlined : Icons.group_outlined,
                                    size: 14,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      statusLine,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            group.state.name.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: badgeFg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}