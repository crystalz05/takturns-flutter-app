import '../../domain/entities/cycle_progress.dart';

class CycleProgressModel extends CycleProgress {
  const CycleProgressModel({
    required super.contributed,
    required super.total,
  });

  /// Useful if your smart contract has a helper function returning `(uint256 contributed, uint256 total)`
  factory CycleProgressModel.fromDeployedContract(List<dynamic> response) {
    return CycleProgressModel(
      contributed: (response[0] as BigInt).toInt(),
      total: (response[1] as BigInt).toInt(),
    );
  }

  factory CycleProgressModel.fromJson(Map<String, dynamic> json) {
    return CycleProgressModel(
      contributed: json['contributed'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contributed': contributed,
      'total': total,
    };
  }
}