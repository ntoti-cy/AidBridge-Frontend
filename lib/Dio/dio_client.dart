import 'package:dio/dio.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      //baseUrl: "http://10.7.21.196:5000/api/auth",
       baseUrl: "http://127.0.0.1:5000/api/auth",

      
      headers: {
        "Content-Type": "application/json",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    )
  );
}