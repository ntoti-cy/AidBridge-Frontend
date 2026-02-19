class Token {
  int? id;
  String tokenValue;
  String nationalId; // Linked to beneficiary
  bool used;

  Token({
    this.id,
    required this.tokenValue,
    required this.nationalId,
    this.used = false,
  });

  // Convert DB Map to Token
  factory Token.fromJson(Map<String, dynamic> map) => Token(
        id: map['id'],
        tokenValue: map['token'],
        nationalId: map['national_id'],
        used: map['used'] == 1,
      );

  // Convert Token to Map for DB insert
  Map<String, dynamic> toMap() => {
        'id': id,
        'token': tokenValue,
        'national_id': nationalId,
        'used': used ? 1 : 0,
      };
}
