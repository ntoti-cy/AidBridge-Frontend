import 'package:aid_bridge/Dio/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final Dio dio = DioClient.dio;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;

  String? get AccessToken => _accessToken;

  // Initialization
  Future<void> init() async {
    _accessToken = await _storage.read(key: 'access_token');
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Future<void> clearAccessToken() async {
    _accessToken = null;

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String secondName,
    required String nationalId,
    required String contact,
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/api/auth/register',
      data: {
        "first_name": firstName,
        "second_name": secondName,
        "national_id": nationalId,
        "contact": contact,
        "email": email,
        "password": password,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  // Login
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/api/auth/login',
      data: {"email": email, "password": password},
    );

    final String accessToken = response.data["access_token"];

    final String? refreshToken = response.data["refresh_token"];

    _accessToken = accessToken;

    await _storage.write(key: "access_token", value: accessToken);

    if (refreshToken != null) {
      await _storage.write(key: "refresh_token", value: refreshToken);
    }

    await _storage.write(key: "last_logged_in_email", value: email);

    _accessToken = accessToken;

    return accessToken;
  }

  // Logout
  Future<void> logout() async {
    try {
      await dio.post('/api/auth/logout');
    } catch (_) {}

    await clearAccessToken();
  }

  // Refresh
  Future<Map<String, dynamic>> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: "refresh_token");

    if (refreshToken == null) {
      throw Exception("No refresh token found");
    }

    final response = await dio.post(
      "/api/auth/refresh",
      options: Options(headers: {"Authorization": "Bearer $refreshToken"}),
    );

    final data = Map<String, dynamic>.from(response.data);

    _accessToken = data["access_token"];

    await _storage.write(key: "access_token", value: data["access_token"]);

    if (data["refresh_token"] != null) {
      await _storage.write(key: "refresh_token", value: data["refresh_token"]);
    }

    return data;
  }

  //Token Status
  Future<Map<String, dynamic>> getTokenStatus() async {
    final response = await dio.get("/api/user/token-status");

    return Map<String, dynamic>.from(response.data);
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await dio.get("/api/crud/me");

    return Map<String, dynamic>.from(response.data);
  }

  // Beneficiary
  Future<Map<String, dynamic>> requestAidToken() async {
    final response = await dio.post("/api/user/request-token");

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getTokenHistory() async {
    final response = await dio.get("/api/user/token-history");

    return Map<String, dynamic>.from(response.data);
  }

  Future<void> completeProfile(Map<String, dynamic> data) async {
    await dio.post("/api/crud/complete-profile", data: data);
  }

  // Password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await dio.post(
      "/api/crud/change-password",
      data: {"old_password": oldPassword, "new_password": newPassword},
    );
  }

  // OFFICER
  // Verify QR/manual token
  Future<Map<String, dynamic>> verifyToken(String aidToken) async {
    final response = await dio.post(
      '/api/officer/verify-token',
      data: {"aid_token": aidToken},
    );

    return response.data;
  }

  // Collect aid
  Future<Map<String, dynamic>> collectAid(String aidToken) async {
    final response = await dio.post(
      '/api/officer/collect-aid',
      data: {"aid_token": aidToken},
    );

    return response.data;
  }

  // Download beneficiaries for offline use
  Future<Map<String, dynamic>> downloadBeneficiaries() async {
    final response = await dio.get('/api/officer/download-beneficiaries');

    return response.data;
  }

  // Recent officer activity
  Future<List<Map<String, dynamic>>> recentActivity() async {
    final response = await dio.get('/api/officer/recent-activity');

    return List<Map<String, dynamic>>.from(response.data);
  }

  //Sync
  Future<Map<String, dynamic>> synchronize(
    List<Map<String, dynamic>> records,
  ) async {
    final response = await dio.post(
      "/api/officer/sync",
      data: {"records": records},
    );

    return Map<String, dynamic>.from(response.data);
  }
}
