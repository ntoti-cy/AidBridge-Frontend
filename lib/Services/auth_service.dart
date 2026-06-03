import 'package:aid_bridge/Dio/dio_client.dart';
import 'package:dio/dio.dart';


class AuthService {
  final Dio dio = DioClient.dio;

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

    return response.data;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/api/auth/login',
      data: {
        "email": email,
        "password": password,
      },
    );

    return response.data["access_token"];
  }


  Future<Map<String, dynamic>> getUserProfile(String token) async {
  final response = await dio.get(
    '/api/crud/me', 
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
  return response.data;
}
Future<Map<String, dynamic>> requestAidToken(String token) async {
    final response = await dio.post(
      '/api/user/request-token',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return response.data;
  }

Future<Map<String, dynamic>> getTokenHistory(String token) async {
    final response = await dio.get(
      '/api/user/token-history',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return response.data;
  }



}


