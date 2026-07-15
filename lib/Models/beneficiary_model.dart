class Beneficiary {
  int? id;
  String name;
  String aidToken;
  String nationalId;
  String tokenStatus;
  int totalMembers;
  int dependentsCount;
  double incomeLevel;
  bool disabilityPresent;
  String distributionCenter;

  Beneficiary({
    this.id,
    required this.name,
    required this.aidToken,
    required this.nationalId,
    required this.tokenStatus,
    required this.totalMembers,
    required this.dependentsCount,
    required this.incomeLevel,
    required this.disabilityPresent,
    required this.distributionCenter,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) => Beneficiary(
    id: json['id'],
    name: json['name'],
    aidToken: json['aid_token'],
    nationalId: json['national_id'].toString(),
    tokenStatus: json['token_status'],
    totalMembers: json['total_members'] ?? 0,
    dependentsCount: json['dependents_count'] ?? 0,
    incomeLevel: (json['income_level'] ?? 0).toDouble(),
    disabilityPresent: (() {
      final value = json['disability_present'];

      if (value is bool) return value;
      if (value is int) return value == 1;

      return false;
    })(),
    distributionCenter: json['distribution_center'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'aid_token': aidToken,
    'national_id': nationalId,
    'token_status': tokenStatus,
    'total_members': totalMembers,
    'dependents_count': dependentsCount,
    'income_level': incomeLevel,
    'disability_present': disabilityPresent ? 1 : 0,
    'distribution_center': distributionCenter,
  };
}
