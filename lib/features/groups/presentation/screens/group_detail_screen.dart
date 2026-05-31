import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/core/utils/extensions.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/group_detail/group_detail_bloc.dart';

import '../blocs/group_detail/group_detail_event.dart';
import '../blocs/group_detail/group_detail_state.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupAddress;
  const GroupDetailScreen({super.key, required this.groupAddress});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupDetailBloc>().add(LoadGroupDetailEvent(widget.groupAddress));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Detail')),
      body: BlocConsumer<GroupDetailBloc, GroupDetailState>(
        listener: (context, state) {
          if (state is GroupDetailTxSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is GroupDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is GroupDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          GroupDetailLoaded? data;
          bool isTransacting = false;
          String txMessage = '';

          if (state is GroupDetailLoaded) {
            data = state;
          } else if (state is GroupDetailTransacting) {
            data = state.previousState;
            isTransacting = true;
            txMessage = state.message;
          } else if (state is GroupDetailTxSuccess) {
            data = state.data;
          }

          if (data == null) {
            return Center(
              child: Text(
                state is GroupDetailError ? state.message : 'Unknown error',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<GroupDetailBloc>().add(RefreshGroupDetailEvent(widget.groupAddress)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context, data),
                if (isTransacting)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 16),
                        Text(txMessage, style: const TextStyle(color: AppColors.primary)),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                _buildActionArea(context, data),
                const SizedBox(height: 24),
                Text('Members', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildMembersList(context, data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GroupDetailLoaded data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cycle ${data.group.currentCycle}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    data.group.state.name.toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn('Amount', data.group.contributionAmount.toUsdc(decimalPlaces: 0)),
                _StatColumn('Duration', data.group.cycleDuration.toInt().cycleDurationLabel),
                _StatColumn('Progress', '${data.cycleProgress.contributed}/${data.cycleProgress.total}'),
              ],
            ),
            if (data.group.isActive) ...[
              const Divider(height: 32),
              Text(
                'Deadline: ${data.group.cycleDeadline.toDeadlineStr}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DateTime.now().millisecondsSinceEpoch > data.group.cycleDeadline * 1000
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, GroupDetailLoaded data) {
    if (data.group.isPending) {
      if (data.isAdmin && data.group.isFull) {
        return ElevatedButton(
          onPressed: () => context.read<GroupDetailBloc>().add(StartGroupEvent(widget.groupAddress)),
          child: const Text('Start Group'),
        );
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
        child: Text(
          'Waiting for members to join... (${data.group.members.length}/${data.group.maxMembers})',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (data.group.isActive) {
      return ElevatedButton(
        onPressed: data.myContributed ? null : () => context.read<GroupDetailBloc>().add(ContributeEvent(widget.groupAddress)),
        style: ElevatedButton.styleFrom(
          backgroundColor: data.myContributed ? AppColors.surfaceVariant : AppColors.primary,
          foregroundColor: data.myContributed ? AppColors.primary : Colors.black,
        ),
        child: Text(data.myContributed ? 'Contributed for this cycle' : 'Contribute ${data.group.contributionAmount.toUsdc()}'),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMembersList(BuildContext context, GroupDetailLoaded data) {
    return Column(
      children: data.members.map((member) {
        final isMe = member.address.toLowerCase() == data.myAddress.toLowerCase();
        final isRecipient = data.group.isActive && member.address.toLowerCase() == data.group.currentRecipient.toLowerCase();

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isRecipient ? AppColors.primary : AppColors.surfaceVariant,
            child: Icon(
              isRecipient ? Icons.monetization_on : Icons.person,
              color: isRecipient ? Colors.black : AppColors.secondary,
            ),
          ),
          title: Text(
            '${member.address.truncated}${isMe ? " (You)" : ""}',
            style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
          ),
          subtitle: Text('Total: ${member.totalContributed.toUsdc(decimalPlaces: 0)}'),
          trailing: data.group.isActive
              ? Icon(
                  member.hasContributedThisCycle ? Icons.check_circle : Icons.pending,
                  color: member.hasContributedThisCycle ? AppColors.success : AppColors.primary,
                )
              : null,
          onLongPress: data.group.isActive && !member.hasContributedThisCycle && DateTime.now().millisecondsSinceEpoch > data.group.cycleDeadline * 1000
              ? () {
                  // Admin or anyone can flag if overdue
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Flag Defaulter?'),
                      content: const Text('This will slash their collateral and trigger a vote.'),
                      actions: [
                        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            context.pop();
                            context.read<GroupDetailBloc>().add(FlagDefaulterEvent(
                                  groupAddress: data.group.address,
                                  memberAddress: member.address,
                                ));
                          },
                          child: const Text('Flag'),
                        ),
                      ],
                    ),
                  );
                }
              : null,
        );
      }).toList(),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
