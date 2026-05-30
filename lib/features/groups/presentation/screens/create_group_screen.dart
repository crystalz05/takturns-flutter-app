import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takturns_flutter_app/core/theme/app_theme.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/create_group_bloc.dart';
import 'package:takturns_flutter_app/features/groups/presentation/blocs/home_bloc.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _amountController = TextEditingController();
  final _membersController = TextEditingController();
  int _durationDays = 7;
  int _minGrade = 1;

  @override
  void dispose() {
    _amountController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: BlocConsumer<CreateGroupBloc, CreateGroupState>(
        listener: (context, state) {
          if (state is CreateGroupSuccess) {
            HomeBloc.saveGroupAddress(state.groupAddress).then((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group created successfully!'), backgroundColor: AppColors.success),
              );
              context.pop();
            });
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
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Contribution Amount (USDC)',
                    hintText: 'e.g. 10',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  value: _durationDays, // ignore: deprecated_member_use
                  decoration: const InputDecoration(labelText: 'Cycle Duration'),
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('Weekly')),
                    DropdownMenuItem(value: 14, child: Text('Bi-weekly')),
                    DropdownMenuItem(value: 30, child: Text('Monthly')),
                  ],
                  onChanged: (val) => setState(() => _durationDays = val!),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _membersController,
                  decoration: const InputDecoration(
                    labelText: 'Max Members',
                    hintText: 'e.g. 5',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  value: _minGrade, // ignore: deprecated_member_use
                  decoration: const InputDecoration(labelText: 'Minimum Grade to Join'),
                  items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text('Grade ${i + 1}'))),
                  onChanged: (val) => setState(() => _minGrade = val!),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    final members = int.tryParse(_membersController.text) ?? 0;
                    if (amount <= 0 || members < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid input'), backgroundColor: AppColors.warning),
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
                  child: const Text('Deploy Group Contract'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
