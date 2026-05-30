import 'package:takturns_flutter_app/features/groups/domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.address,
    required super.admin,
    required super.contributionAmount,
    required super.cycleDuration,
    required super.maxMembers,
    required super.currentCycle,
    required super.state,
    required super.members,
    required super.currentRecipient,
    required super.cycleDeadline,
    required super.minGrade,
    required super.token,
  });

  /// Factory to parse data directly from a web3dart contract read call response.
  /// Matches typical Solidity struct layout order.
  factory GroupModel.fromDeployedContract(String contractAddress, List<dynamic> response) {
    return GroupModel(
      address: contractAddress,
      admin: (response[0] as String),
      contributionAmount: response[1] is BigInt ? response[1] as BigInt : BigInt.from(response[1] as num),
      cycleDuration: response[2] is BigInt ? response[2] as BigInt : BigInt.from(response[2] as num),
      maxMembers: (response[3] as BigInt).toInt(),
      currentCycle: (response[4] as BigInt).toInt(),
      state: (response[5] as BigInt).toInt().toGroupState(),
      members: (response[6] as List).map((m) => m.toString()).toList(),
      currentRecipient: (response[7] as String),
      cycleDeadline: (response[8] as BigInt).toInt(),
      minGrade: (response[9] as BigInt).toInt(),
      token: (response[10] as String),
    );
  }

  /// Standard factory for JSON/Backend maps
  factory GroupModel.fromJson(Map<String, dynamic> json, String contractAddress) {
    return GroupModel(
      address: contractAddress,
      admin: json['admin'] as String,
      contributionAmount: BigInt.parse(json['contributionAmount'].toString()),
      cycleDuration: BigInt.parse(json['cycleDuration'].toString()),
      maxMembers: json['maxMembers'] as int,
      currentCycle: json['currentCycle'] as int,
      state: (json['state'] as int).toGroupState(),
      members: List<String>.from(json['members'] as List),
      currentRecipient: json['currentRecipient'] as String,
      cycleDeadline: json['cycleDeadline'] as int,
      minGrade: json['minGrade'] as int,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': admin,
      'contributionAmount': contributionAmount.toString(),
      'cycleDuration': cycleDuration.toString(),
      'maxMembers': maxMembers,
      'currentCycle': currentCycle,
      'state': state.index,
      'members': members,
      'currentRecipient': currentRecipient,
      'cycleDeadline': cycleDeadline,
      'minGrade': minGrade,
      'token': token,
    };
  }
}