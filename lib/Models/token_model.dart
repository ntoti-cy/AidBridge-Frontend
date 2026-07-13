class Token {
  final String aidToken;
  final String session;
  final String status;
  final String? issuedAt;
  final String? expiresAt;
  final bool used;

  Token({
    required this.aidToken,
    required this.session,
    required this.status,
    this.issuedAt,
    this.expiresAt,
    this.used = false,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      aidToken: json["aid_token"] ?? "",
      session: json["session"] ?? "",
      status: json["status"] ?? "",
      issuedAt: json["issued_at"],
      expiresAt: json["expires_at"],
      used: (json["used"] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "aid_token": aidToken,
      "session": session,
      "status": status,
      "issued_at": issuedAt,
      "expires_at": expiresAt,
      "used": used ? 1 : 0,
    };
  }
}
