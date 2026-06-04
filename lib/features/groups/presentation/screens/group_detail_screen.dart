import 'dart:ffi';

import 'package:flutter/cupertino.dart';
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F4A23)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Group Details',
          style: TextStyle(color: Color(0xFF0F4A23), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
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
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0F4A23)));
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

          final progressRatio = data.cycleProgress.total > 0
              ? data.cycleProgress.contributed / data.cycleProgress.total
              : 0.0;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => context.read<GroupDetailBloc>().add(RefreshGroupDetailEvent(widget.groupAddress)),
                  color: const Color(0xFF0F4A23),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (isTransacting) _buildTransactionBanner(txMessage),

                      // Section 1: Core Target Info Card
                      _buildMainMetricsCard(context, data, progressRatio),
                      const SizedBox(height: 20),

                      // Section 2: Recipient Status Row Banner
                      if (data.group.isActive) _buildRecipientCard(data),
                      const SizedBox(height: 24),

                      // Section 3: Sub-List Header Mapping
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Member Status',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'View All',
                              style: TextStyle(color: Color(0xFF0F4A23), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Section 4: Members Interactive Listing
                      _buildMembersContainer(context, data),
                    ],
                  ),
                ),
              ),

              // Section 5: Persistent Floating Bottom Action Area Dock
              _buildStickyActionButtonDock(context, data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4A23).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F4A23))),
          const SizedBox(width: 12),
          Text(message, style: const TextStyle(color: Color(0xFF0F4A23), fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMainMetricsCard(BuildContext context, GroupDetailLoaded data, double progressRatio) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative structural accent circle background hook
            Positioned(
              top: -30,
              right: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: const Color(0xFFEBF5EE).withOpacity(0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.group.address.truncated, // Fallback or dynamic data parsing properties
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), height: 1.2),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Cycle ${data.group.currentCycle} of ${data.group.maxMembers}', // Assuming round counts link to total members
                              style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // Colored State Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBF3E5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              data.group.state.name.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Concentric Nested Center Progress Circular Block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 90,
                          width: 90,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 84,
                                width: 84,
                                child: CircularProgressIndicator(
                                  value: progressRatio,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  color: const Color(0xFF66BB6A),
                                  strokeWidth: 7,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${data.cycleProgress.contributed}',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                  ),
                                  Text(
                                    '/ ${data.cycleProgress.total}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Contributions on Track',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.cycleProgress.contributed} out of ${data.cycleProgress.total} members have submitted their funds for Cycle ${data.group.currentCycle}.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
                        ),
                        if (data.group.isActive) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Next payout in ${toRemainingDaysLabel(data.group.cycleDeadline)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }


  Widget _buildRecipientCard(GroupDetailLoaded data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424B45), // Matches muted dark gray block token
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Color(0xFF81C784), shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF424B45), size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'CURRENT RECIPIENT',
                      style: TextStyle(color: Color(0xFFA3B899), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.stars, color: Color(0xFF81C784), size: 14),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Sarah Jenkins', // Context default mock or pass parameters dynamically
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  data.group.currentRecipient.truncated,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
              ],
            ),
          ),
          // Subtle background stack overlay matching corner asset icon placement
          Icon(Icons.payment, color: Colors.white.withOpacity(0.05), size: 48),
        ],
      ),
    );
  }

  Widget _buildMembersContainer(BuildContext context, GroupDetailLoaded data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        children: data.members.map((member) {
          final isMe = member.address.toLowerCase() == data.myAddress.toLowerCase();

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFEEEEEE),
                  child: Icon(Icons.person, color: Colors.grey, size: 22),
                ),
                title: Text(
                  isMe ? "${member.address.truncated} (You)" : member.address.truncated, // Custom handling parsing
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontSize: 15),
                ),
                subtitle: Text(
                  'Collateral: ${member.collateralDeposited.toUsdc(decimalPlaces: 0)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: member.hasContributed
                    ? const Icon(Icons.check_circle, color: Color(0xFF0F4A23), size: 22)
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 22),
                onLongPress: data.group.isActive && !member.hasContributed && DateTime.now().millisecondsSinceEpoch > data.group.cycleDeadline * 1000
                    ? () => _showFlagDefaulterDialog(context, data, member.address)
                    : null,
              ),
              if (data.members.last != member) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStickyActionButtonDock(BuildContext context, GroupDetailLoaded data) {
    final isMember = data.members.any((m) => m.address.toLowerCase() == data.myAddress.toLowerCase());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFEAEAEA), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Upper State Row descriptor layout matching
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Status:', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Icon(
                    data.myContributed ? Icons.check_circle_outline : Icons.error_outline,
                    size: 16,
                    color: data.myContributed ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data.myContributed ? 'Contributed' : 'Not Yet Contributed',
                    style: TextStyle(
                      color: data.myContributed ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Render Action Button based on operational smart contract parameters
          if (!isMember)
            _buildDockedButton(
              label: 'Join Group Pool',
              icon: Icons.group_add_outlined,
              onPressed: (data.group.isPending && !data.group.isFull)
                  ? () => context.pushNamed('join-group', queryParameters: {'address': widget.groupAddress})
                  : null,
            )
          else if (data.group.isPending)
            if (data.isAdmin && data.group.members.length >= 2)
              Column(
                children: [
                  _buildDockedButton(
                    label: 'Start Group Execution',
                    icon: Icons.play_circle_outline,
                    onPressed: () => context.read<GroupDetailBloc>().add(StartGroupEvent(widget.groupAddress)),
                  ),
                  if (!data.group.isFull) ...[
                    const SizedBox(height: 8),
                    Text(
                      'You can start now with ${data.group.members.length} members, or wait for up to ${data.group.maxMembers}.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ]
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'Waiting for members to join... (${data.group.members.length}/${data.group.maxMembers})',
                  textAlign: TextAlign.center,
                ),
              )
          else if (data.group.isActive)
              _buildDockedButton(
                label: data.myContributed ? 'Cycle Funds Submitted' : 'Contribute Now',
                icon: Icons.account_balance_wallet_outlined,
                onPressed: data.myContributed
                    ? null
                    : () => context.read<GroupDetailBloc>().add(ContributeEvent(widget.groupAddress)),
              )
            else
              const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildDockedButton({required String label, required IconData icon, required VoidCallback? onPressed}) {
    final isDisabled = onPressed == null;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? const Color(0xFFE0E0E0) : const Color(0xFF0F4A23),
        foregroundColor: isDisabled ? Colors.grey : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  void _showFlagDefaulterDialog(BuildContext context, GroupDetailLoaded data, String targetMember) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Flag Defaulter?'),
        content: const Text('This will slash their collateral and trigger a collective voting sequence.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
            onPressed: () {
              context.pop();
              context.read<GroupDetailBloc>().add(FlagDefaulterEvent(
                groupAddress: data.group.address,
                memberAddress: targetMember,
              ));
            },
            child: const Text('Flag Defaulter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}



  String toRemainingDaysLabel(int value) {
    final difference = (value * 1000) - DateTime.now().millisecondsSinceEpoch;
    if (difference <= 0) return "0 days";
    final days = (difference / (1000 * 60 * 60 * 24)).ceil();
    return "$days ${days == 1 ? 'day' : 'days'}";
  }