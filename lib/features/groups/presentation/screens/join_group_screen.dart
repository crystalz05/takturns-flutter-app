import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/core/utils/extensions.dart';
import 'package:takturns_flutter_app/core/utils/mask_wallet.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/join_group/join_group_bloc.dart';

import '../blocs/join_group/join_group_event.dart';
import '../blocs/join_group/join_group_state.dart';

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
    _addressController = TextEditingController(text: widget.initialAddress ?? "");

    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _preview());
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 26),
          ),
        ),
        title: Text(
          'Join a Group',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<JoinGroupBloc, JoinGroupState>(
        listener: (context, state) {
          if (state is JoinGroupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Joined group successfully!'), backgroundColor: AppColors.success),
            );
            context.pop();
          } else if (state is JoinGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Scrollable main dashboard contents
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enter a contract address or scan an invite code to securely join an existing savings pool.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.outline,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 1: Input Field Card Wrapper
                        Text(
                          'Contract Address',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _addressController,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter contract address (0x...)',
                                    hintStyle: TextStyle(color: AppColors.outline),
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search, color: AppColors.primary),
                                onPressed: _preview,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ensure the address is on the supported network.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline),
                        ),
                        const SizedBox(height: 32),

                        // Loading / State Indicators
                        if (state is JoinGroupLoadingPreview || state is JoinGroupJoining) ...[
                          const SizedBox(height: 60),
                          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              state is JoinGroupJoining ? state.message : 'Fetching real-time group specifications...',
                              style: const TextStyle(color: AppColors.outline, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ]

                        // Section 2: Loaded Group Specification Card Preview
                        else if (state is JoinGroupPreviewLoaded) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -22,
                                      left: 16,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            color: AppColors.secondaryContainer,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                            ]
                                        ),
                                        child: const Icon(Icons.group_outlined, color: AppColors.onSecondaryContainer, size: 28),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Managed by ${maskWalletAddress(state.group.admin)}',
                                              style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            CircleAvatar(radius: 4, backgroundColor: Colors.green),
                                            SizedBox(width: 6),
                                            Text('Open', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: _buildGridItem(Icons.payment_outlined, 'Contribution', state.group.contributionAmount.toUsdc())),
                                            Expanded(child: _buildGridItem(Icons.history_toggle_off, 'Frequency', state.group.cycleDuration.toInt().cycleDurationLabel)),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(child: _buildGridItem(Icons.people_alt_outlined, 'Members', '${state.group.members.length} / ${state.group.maxMembers} Joined')),
                                            Expanded(child: _buildGridItem(Icons.account_balance_wallet_outlined, 'Total Pool', '\$${(double.tryParse(state.group.contributionAmount.toUsdc().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0) * state.group.maxMembers}')),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Capacity Fill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                          Text(
                                            '${((state.group.members.length / state.group.maxMembers) * 100).toInt()}%',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: state.group.members.length / state.group.maxMembers,
                                          backgroundColor: AppColors.surfaceContainerHigh,
                                          color: AppColors.primary,
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 60),
                          Icon(Icons.search_off_outlined, color: AppColors.outline.withOpacity(0.4), size: 64),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'No dynamic group specifications queried yet.',
                              style: TextStyle(color: AppColors.outline, fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Section 3: Persistent Sticky Bottom Action Dock Container
                if (state is JoinGroupPreviewLoaded) _buildStickyActionDock(state),
              ],
            ),
          );
        },
      ),
    );
  }

  // Extracted sticky footer area supporting terms context labels and button parameters
  Widget _buildStickyActionDock(JoinGroupPreviewLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDockedButton(
            label: state.group.isFull ? 'Group Capacity Full' : 'Confirm & Join Group',
            icon: Icons.arrow_forward,
            onPressed: state.group.isFull
                ? null
                : () => context.read<JoinGroupBloc>().add(ConfirmJoinEvent(state.group.address)),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'By joining, you agree to the smart contract terms.',
              style: TextStyle(color: AppColors.outline, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockedButton({required String label, required IconData icon, required VoidCallback? onPressed}) {
    final isDisabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? const Color(0xFFE0E0E0) : AppColors.primary,
          foregroundColor: isDisabled ? Colors.grey : AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.outline.withOpacity(0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.outline, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}