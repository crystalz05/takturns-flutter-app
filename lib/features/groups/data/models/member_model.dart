import '../../domain/entities/member.dart';

class MemberModel extends Member {
  const MemberModel({
    required super.address,
    required super.hasContributedThisCycle,
    required super.totalContributed,
  });

  /// Factory to parse Member Struct arrays from EVM responses
  factory MemberModel.fromDeployedContract(List<dynamic> response) {
    return MemberModel(
      address: response[0] as String,
      hasContributedThisCycle: response[1] as bool,
      totalContributed: response[2] is BigInt ? response[2] as BigInt : BigInt.from(response[2] as num),
    );
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      address: json['address'] as String,
      hasContributedThisCycle: json['hasContributedThisCycle'] as bool,
      totalContributed: BigInt.parse(json['totalContributed'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'hasContributedThisCycle': hasContributedThisCycle,
      'totalContributed': totalContributed.toString(),
    };
  }
}