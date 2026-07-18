class Token {
  final String aidToken;
  final String tokenStatus;
  final String centerName;
  final String? tokenIssuedAt;
  final String? expiryTime;

  Token({
    required this.aidToken,
    required this.tokenStatus,
    required this.centerName,
    this.tokenIssuedAt,
    this.expiryTime,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      aidToken: json["aid_token"] ?? "",
      tokenStatus: json["token_status"] ?? "",
      centerName: json["center_name"] ?? "",
      tokenIssuedAt: json["token_issued_at"],
      expiryTime: json["expiry_time"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "aid_token": aidToken,
      "token_status": tokenStatus,
      "center_name": centerName,
      "token_issued_at": tokenIssuedAt,
      "expiry_time": expiryTime,
    };
  }
}
