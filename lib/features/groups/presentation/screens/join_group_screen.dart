import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/core/utils/extensions.dart';
import 'package:takturns_flutter_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/join_group_bloc.dart';

class JoinGroupScreen extends StatefulWidget {
  final String? initialAddress;
  const JoinGroupScreen({super.key, this.initialAddress});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _preview();
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _preview() {
    final addr = _addressController.text.trim();
    if (addr.isNotEmpty && addr.isValidEthAddress) {
      context.read<JoinGroupBloc>().add(PreviewGroupEvent(addr));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid address format.'), backgroundColor: AppColors.warning),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Group')),
      body: BlocConsumer<JoinGroupBloc, JoinGroupState>(
        listener: (context, state) {
          if (state is JoinGroupSuccess) {
            HomeBloc.saveGroupAddress(state.groupAddress).then((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joined group successfully!'), backgroundColor: AppColors.success),
              );
              context.pop();
            });
          } else if (state is JoinGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Group Contract Address',
                          hintText: '0x...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _preview,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 56)),
                      child: const Text('Find'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (state is JoinGroupLoadingPreview || state is JoinGroupJoining) ...[
                  const Spacer(),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  Center(child: Text(state is JoinGroupJoining ? state.message : 'Loading group details...')),
                  const Spacer(),
                ] else if (state is JoinGroupPreviewLoaded) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Group Details', style: Theme.of(context).textTheme.titleLarge),
                          const Divider(height: 32),
                          _DetailRow(label: 'Contribution', value: state.group.contributionAmount.toUsdc()),
                          _DetailRow(label: 'Duration', value: state.group.cycleDuration.toInt().cycleDurationLabel),
                          _DetailRow(label: 'Members', value: '${state.group.members.length} / ${state.group.maxMembers}'),
                          _DetailRow(label: 'Min Grade', value: '${state.group.minGrade}'),
                          const Divider(height: 32),
                          _DetailRow(label: 'Collateral Required', value: state.collateral.toUsdc(), highlight: true),
                          const SizedBox(height: 8),
                          Text(
                            'Collateral is returned when the group completes successfully.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: state.group.isFull ? null : () {
                      context.read<JoinGroupBloc>().add(ConfirmJoinEvent(state.group.address));
                    },
                    child: Text(state.group.isFull ? 'Group is Full' : 'Approve & Join'),
                  ),
                ] else ...[
                  const Spacer(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DetailRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: highlight ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
