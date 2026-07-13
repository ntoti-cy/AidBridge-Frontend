import 'package:aid_bridge/Services/auth_service.dart';
import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://aidbridge-backend-38ei.onrender.com",
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static bool _initialized = false;
  static bool _isRefreshing = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    final authService = AuthService();

    dio.interceptors.add(
      InterceptorsWrapper(
        // Attach Access Token
        onRequest: (options, handler) {
          final token = authService.AccessToken;

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },

        // Handle 401
        onError: (DioException err, handler) async {
          final request = err.requestOptions;

          // Ignore refresh endpoint
          if (request.path.contains("/api/auth/refresh")) {
            await authService.clearAccessToken();
            return handler.next(err);
          }

          if (err.response?.statusCode != 401) {
            return handler.next(err);
          }

          if (_isRefreshing) {
            return handler.next(err);
          }

          _isRefreshing = true;

          try {
            final tokens = await authService.refreshAccessToken();

            final newAccessToken = tokens["access_token"];

            authService.setAccessToken(newAccessToken);

            request.headers["Authorization"] = "Bearer $newAccessToken";

            final response = await dio.fetch(request);

            _isRefreshing = false;

            return handler.resolve(response);
          } catch (e) {
            _isRefreshing = false;

            await authService.clearAccessToken();

            return handler.next(err);
          }
        },
      ),
    );
  }
}
