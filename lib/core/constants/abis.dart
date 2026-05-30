/// ABI definitions for all contracts
class ContractAbis {
  ContractAbis._();

  static const String factory = r'''
[
  {"inputs":[{"internalType":"address","name":"_groupImplementation","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},
  {"inputs":[],"name":"FailedDeployment","type":"error"},
  {"inputs":[{"internalType":"uint256","name":"balance","type":"uint256"},{"internalType":"uint256","name":"needed","type":"uint256"}],"name":"InsufficientBalance","type":"error"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"member","type":"address"},{"indexed":false,"internalType":"uint256","name":"currentCount","type":"uint256"}],"name":"ConsecutiveCompletionRecorded","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"groupAddress","type":"address"},{"indexed":true,"internalType":"address","name":"creator","type":"address"},{"indexed":false,"internalType":"uint8","name":"minGrade","type":"uint8"},{"indexed":false,"internalType":"address","name":"token","type":"address"}],"name":"GroupCreated","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"member","type":"address"},{"indexed":true,"internalType":"address","name":"group","type":"address"}],"name":"MemberBlacklisted","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"member","type":"address"},{"indexed":false,"internalType":"uint8","name":"newGrade","type":"uint8"}],"name":"MemberPromoted","type":"event"},
  {"inputs":[],"name":"MAX_GRADE","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"PROMOTION_THRESHOLD","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"allGroups","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"_user","type":"address"},{"internalType":"uint8","name":"_minGrade","type":"uint8"}],"name":"canJoinGroup","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"uint8","name":"_minGrade","type":"uint8"},{"internalType":"uint256","name":"_contribution","type":"uint256"},{"internalType":"uint256","name":"_cycleDuration","type":"uint256"},{"internalType":"uint256","name":"_maxMembers","type":"uint256"},{"internalType":"address","name":"_token","type":"address"}],"name":"createGroup","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[{"internalType":"uint256","name":"_contribution","type":"uint256"},{"internalType":"uint8","name":"_minGrade","type":"uint8"}],"name":"getCollateralAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"uint8","name":"_grade","type":"uint8"}],"name":"getGradeRules","outputs":[{"components":[{"internalType":"uint256","name":"minContribution","type":"uint256"},{"internalType":"uint256","name":"maxContribution","type":"uint256"},{"internalType":"uint256","name":"collateralPercent","type":"uint256"}],"internalType":"struct ITakturnsFactory.GradeRules","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"_user","type":"address"}],"name":"getMemberProfile","outputs":[{"components":[{"internalType":"uint8","name":"grade","type":"uint8"},{"internalType":"uint256","name":"consecutiveCompletions","type":"uint256"},{"internalType":"bool","name":"isBlacklisted","type":"bool"}],"internalType":"struct ItakturnsFactory.MemberProfile","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"groupImplementation","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"isGroup","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"_user","type":"address"}],"name":"recordSuccessfulCycle","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[{"internalType":"address","name":"_user","type":"address"}],"name":"reportDefault","outputs":[],"stateMutability":"nonpayable","type":"function"}
]
''';

  static const String group = r'''
[
  {"inputs":[{"internalType":"address","name":"_factory","type":"address"},{"internalType":"uint8","name":"_minGrade","type":"uint8"},{"internalType":"uint256","name":"_contributionAmount","type":"uint256"},{"internalType":"uint256","name":"_cycleDuration","type":"uint256"},{"internalType":"uint256","name":"_maxMembers","type":"uint256"},{"internalType":"address","name":"_token","type":"address"},{"internalType":"address","name":"_admin","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"member","type":"address"},{"indexed":false,"internalType":"uint256","name":"cycle","type":"uint256"}],"name":"ContributionMade","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"defaulter","type":"address"}],"name":"DefaulterFlagged","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"recipient","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"cycle","type":"uint256"}],"name":"FundsDistributed","type":"event"},
  {"anonymous":false,"inputs":[],"name":"GroupCompleted","type":"event"},
  {"anonymous":false,"inputs":[],"name":"GroupDissolved","type":"event"},
  {"anonymous":false,"inputs":[],"name":"GroupStarted","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"member","type":"address"}],"name":"MemberJoined","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"voter","type":"address"},{"indexed":false,"internalType":"uint8","name":"vote","type":"uint8"}],"name":"VoteCast","type":"event"},
  {"anonymous":false,"inputs":[],"name":"VoteResolved","type":"event"},
  {"inputs":[],"name":"admin","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"uint8","name":"_vote","type":"uint8"}],"name":"castVote","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[],"name":"contribute","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[],"name":"contributionAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"currentCycle","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"cycleDeadline","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"cycleDuration","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"factory","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"_member","type":"address"}],"name":"flagDefaulter","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[],"name":"getCurrentRecipient","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"getCycleProgress","outputs":[{"internalType":"uint256","name":"contributed","type":"uint256"},{"internalType":"uint256","name":"total","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"getMembers","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"_member","type":"address"}],"name":"hasContributed","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"joinGroup","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[],"name":"maxMembers","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"minGrade","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"resolveVote","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[],"name":"startGroup","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[],"name":"state","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"token","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"_member","type":"address"}],"name":"totalContributed","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}
]
''';

  static const String erc20 = r'''
[
  {"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}
]
''';
}
