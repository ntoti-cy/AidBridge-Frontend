import 'package:aid_bridge/Controllers/history/history_state.dart';
import 'package:aid_bridge/Local/offline_user.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final AuthService authService;
  final OfflineUser offlineUser = OfflineUser();

  HistoryCubit(this.authService)
      : super(HistoryInitial());

  Future<void> loadHistory() async {
    emit(HistoryLoading());

    try {
      final response =
          await authService.getTokenHistory();

      final history =
          List<Map<String, dynamic>>.from(
        response["history"] ?? [],
      );

      await offlineUser.saveHistory(history);

      emit(
        HistoryLoaded(
          history: history,
          offline: false,
        ),
      );
    }

    on DioException {
      final history =
          await offlineUser.getHistory();

      emit(
        HistoryLoaded(
          history: history,
          offline: true,
        ),
      );
    }

    catch (e) {
      emit(
        HistoryFailure(
          e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}