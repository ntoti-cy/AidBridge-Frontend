class Token {
  final String aidToken;
  final String tokenStatus;
  final String centerName;
  final String? tokenissuedAt;
  final String? expiresTime;

  Token({
    required this.aidToken,
    required this.tokenStatus,
    required this.centerName,
    this.tokenissuedAt,
    this.expiresTime,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      aidToken: json["aid_token"] ?? "",
      tokenStatus: json["session"] ?? "",
      centerName: json["status"] ?? "",
      tokenissuedAt: json["issued_at"],
      expiresTime: json["expires_at"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "aid_token": aidToken,
      "session": tokenStatus,
      "status": centerName,
      "issued_at": tokenissuedAt,
      "expires_at": expiresTime,
    };
  }
}
