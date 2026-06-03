import '../../domain/entities/member.dart';

class MemberModel extends Member {
  const MemberModel({
    required super.address,
    required super.hasJoined,
    required super.hasCollected,
    required super.hasDefaulted,
    required super.isLeaving,
    required super.collateralDeposited,
    required super.hasContributed,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      address: json['address'] as String,
      hasJoined: json['hasJoined'] as bool,
      hasCollected: json['hasCollected'] as bool,
      hasDefaulted: json['hasDefaulted'] as bool,
      isLeaving: json['isLeaving'] as bool,
      collateralDeposited: BigInt.parse(json['collateralDeposited'].toString()),
      hasContributed: json['hasContributed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'hasJoined': hasJoined,
      'hasCollected': hasCollected,
      'hasDefaulted': hasDefaulted,
      'isLeaving': isLeaving,
      'collateralDeposited': collateralDeposited.toString(),
      'hasContributed': hasContributed,
    };
  }
}