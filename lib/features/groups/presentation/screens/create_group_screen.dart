import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/create_group/create_group_bloc.dart';

import '../blocs/create_group/create_group_event.dart';
import '../blocs/create_group/create_group_state.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _amountController = TextEditingController();

  int _durationDays = 7;
  double _maxMembers = 4.0;
  int _minGrade = 1; // Tracks selection from Grade 1 to Grade 4

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _totalPot => (double.tryParse(_amountController.text) ?? 0.0) * _maxMembers.toInt();

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
              onPressed: (){
                context.pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 26)
          ),
        ),
        title: Text(
          'Create New Group',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CreateGroupBloc, CreateGroupState>(
        listener: (context, state) {
          if (state is CreateGroupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Group created successfully!'), backgroundColor: AppColors.success),
            );
            context.pop();
          } else if (state is CreateGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateGroupLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(state.message, style: TextStyle(color: AppColors.primary)),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        Text(
                          'Configure your decentralized savings circle. Parameters are immutable once deployed.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.outline,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 1: Contribution Amount
                        _buildCardWrapper(
                          child: Column(
                            children: [
                              _buildCardLabel('Contribution Amount'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('\$', style: TextStyle(fontSize: 22, color: AppColors.outline.withOpacity(0.7), fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  _buildTrailingBadge('USDC'),
                                ],
                              ),
                              const Divider(height: 20),
                              Text(
                                'Amount each member contributes per cycle.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section 2: Cycle Duration (Segmented Switch)
                        _buildCardWrapper(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardLabel('Cycle Duration'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    _buildDurationSegment('Weekly', 7),
                                    _buildDurationSegment('Biweekly', 14),
                                    _buildDurationSegment('Monthly', 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section 3: Max Members (Slider Controls)
                        _buildCardWrapper(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCardLabel('Max Members'),
                                  Text(
                                    '${_maxMembers.toInt()}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.outlineVariant,
                                  inactiveTrackColor: AppColors.surfaceContainerHigh,
                                  thumbColor: Colors.white,
                                  overlayColor: AppColors.primary.withOpacity(0.1),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _maxMembers,
                                  min: 3,
                                  max: 12,
                                  onChanged: (val) => setState(() => _maxMembers = val),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('3 min', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                                  Text('12 max', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section 4: Minimum Grade (Segmented Switch 1 - 4)
                        _buildCardWrapper(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardLabel('Minimum Grade'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: List.generate(4, (index) {
                                    final gradeValue = index + 1;
                                    final bool isSelected = _minGrade == gradeValue;

                                    return Expanded(
                                      child: InkWell(
                                        onTap: () => setState(() => _minGrade = gradeValue),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: isSelected
                                                ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                                : null,
                                          ),
                                          child: Text(
                                            'Grade $gradeValue',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const Divider(height: 20),
                              Text(
                                'Required reputation or credit score tier for members to join this group.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline, height: 1.2),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section 5: Contract Summary Metrics
                        _buildCardWrapper(
                          color: AppColors.surfaceContainerLow,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contract Summary',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Pot per Cycle', style: TextStyle(color: AppColors.outline, fontWeight: FontWeight.w500)),
                                  Text('\$${_totalPot.toStringAsFixed(2)} USDC', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Action Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            final amount = double.tryParse(_amountController.text) ?? 0;
                            final members = _maxMembers.toInt();

                            if (amount <= 0 || members < 2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid contribution details input'), backgroundColor: AppColors.warning),
                              );
                              return;
                            }
                            context.read<CreateGroupBloc>().add(SubmitCreateGroupEvent(
                              minGrade: _minGrade,
                              contributionAmountUsdc: amount,
                              cycleDurationDays: _durationDays,
                              maxMembers: members,
                            ));
                          },
                          icon: const Icon(Icons.rocket_launch_outlined, size: 20),
                          label: const Text('Deploy Contract', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Utility Layout Helpers ---

  Widget _buildCardWrapper({required Widget child, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: child,
    );
  }

  Widget _buildCardLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTrailingBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
      ),
    );
  }

  Widget _buildDurationSegment(String label, int daysValue) {
    final bool isSelected = _durationDays == daysValue;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _durationDays = daysValue),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}