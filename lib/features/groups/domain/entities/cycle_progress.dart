import 'package:equatable/equatable.dart';

class CycleProgress extends Equatable {
  final int contributed;
  final int total;

  const CycleProgress({required this.contributed, required this.total});

  double get percentage => total == 0 ? 0.0 : contributed / total;
  bool get isComplete => contributed >= total;

  @override
  List<Object?> get props => [contributed, total];
}
