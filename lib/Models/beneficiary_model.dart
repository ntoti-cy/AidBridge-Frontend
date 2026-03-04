class Beneficiary {
  int? id;
  String name;
  String aidToken;
  String nationalId;
  String tokenStatus;

  Beneficiary({
    this.id,
    required this.name,
    required this.aidToken,
    required this.nationalId,
    required this.tokenStatus,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) => Beneficiary(
        id: json['id'],
        name: json['name'],
        aidToken: json['aid_token'],
        nationalId: json['national_id'].toString(),
        tokenStatus: json['token_status'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'aid_token': aidToken,
        'national_id': nationalId,
        'token_status': tokenStatus,
      };
}
