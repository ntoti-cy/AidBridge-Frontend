import 'package:aid_bridge/Local/offline_token.dart';
import 'package:aid_bridge/Models/token_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../Services/auth_service.dart';
import 'token_state.dart';

class TokenCubit extends Cubit<TokenState> {
  final AuthService authService;
  final OfflineToken offlineToken =OfflineToken();

  TokenCubit(this.authService)
      : super(TokenInitial());

  /// ===============================
  /// REQUEST NEW TOKEN
  /// ===============================
  Future<void> requestToken() async {
    final response = await authService.requestAidToken();

final token = Token.fromJson(response);

await offlineToken.saveToken(token);

emit(TokenGenerated(response));
    emit(TokenLoading());

    try {
      final response =
          await authService.requestAidToken();

      emit(
        TokenGenerated(response),
      );
    }

    on DioException catch (e) {
      emit(
        TokenFailure(
          e.response?.data["error"] ??
              "Failed to request token.",
        ),
      );
    }

    catch (e) {
      emit(
        TokenFailure(
          e.toString(),
        ),
      );
    }
  }

  /// ===============================
  /// LOAD TOKEN HISTORY
  /// ===============================
  Future<void> loadHistory() async {
  emit(TokenLoading());

  try {
    final response =
        await authService.getTokenHistory();

    emit(
      TokenHistoryLoaded(
        response["tokens"],
      ),
    );
  } on DioException {
    final history = await offlineToken.getHistory();

    emit(
      TokenHistoryLoaded(
        history
            .map((e) => e.toMap())
            .toList(),
      ),
    );
  }
}
}