import 'package:equatable/equatable.dart';

abstract class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();
  @override List<Object?> get props => [];
}

class SubmitCreateGroupEvent extends CreateGroupEvent {
  final int minGrade;
  final double contributionAmountUsdc;
  final int cycleDurationDays;
  final int maxMembers;
  const SubmitCreateGroupEvent({
    required this.minGrade,
    required this.contributionAmountUsdc,
    required this.cycleDurationDays,
    required this.maxMembers,
  });
  @override
  List<Object?> get props => [minGrade, contributionAmountUsdc, cycleDurationDays, maxMembers];
}
