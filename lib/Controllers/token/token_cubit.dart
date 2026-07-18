import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../Local/offline_token.dart';
import '../../Models/token_model.dart';
import '../../Services/auth_service.dart';
import 'token_state.dart';

class TokenCubit extends Cubit<TokenState> {
  final AuthService authService;

  final OfflineToken offlineToken = OfflineToken();

  TokenCubit(this.authService) : super(TokenInitial());

  // Request New Tokens
  Future<void> requestToken() async {
    emit(TokenGenerating());

    try {
      final response = await authService.requestAidToken();

      final token = Token.fromJson(response);

      await offlineToken.saveToken(token);

      emit(TokenGenerated(response));

      //await loadDashboard();
    } on DioException catch (e) {
      final data = e.response?.data;
      emit(
        TokenFailure(
          data is Map
              ? (data["error"] ?? data["message"] ?? "Failed to request token.")
              : "Failed to request token.",
        ),
      );
    } catch (e) {
      emit(TokenFailure(e.toString()));
    }
  }

  Future<void> loadDashboard() async {
    emit(TokenLoading());

    try {
      final status = await authService.getTokenStatus();

      final historyResponse = await authService.getTokenHistory();

      final history = historyResponse["history"] ?? [];
      if (status["has_token"] == true) {
        await offlineToken.saveToken(
          Token(
            aidToken: status["aid_token"]?.toString() ?? "",
            tokenStatus: status["token_status"]?.toString() ?? "active",
            centerName: status["center_name"]?.toString() ?? "",
            tokenIssuedAt: status["token_issued_at"]?.toString(),
            expiryTime: status["expiry_time"]?.toString(),
          ),
        );
      }

      if (history.isNotEmpty) {
        await DBHelper().saveHistory(List<Map<String, dynamic>>.from(history));
      }

      emit(TokenDashboardLoaded(status: status, history: history));
    } on DioException {
      try {
        final offline = await offlineToken.getHistory();

        emit(
          TokenDashboardLoaded(
            status: {"has_token": false},
            history: offline.map((e) => e.toMap()).toList(),
          ),
        );
      } catch (_) {
        emit(
          const TokenDashboardLoaded(status: {"has_token": false}, history: []),
        );
      }
    } catch (e) {
      emit(TokenFailure(e.toString()));
    }
  }
}
