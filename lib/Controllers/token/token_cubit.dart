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

      await loadDashboard();
    } on DioException catch (e) {
      emit(
        TokenFailure(
          e.response?.data["error"] ??
              e.response?.data["message"] ??
              "Failed to request token.",
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
