import 'package:aid_bridge/Controllers/history/history_state.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final AuthService _authService = AuthService();

  HistoryCubit() : super(HistoryInitial());

  Future<void> fetchTokenHistory(String jwtToken) async {
    emit(HistoryLoading());
    try {
      final data = await _authService.getTokenHistory(jwtToken);
      final List<dynamic> list = data['history'] ?? [];
      emit(HistoryLoaded(list));
    } on DioException catch (e) {
      String errorMsg = e.response?.data['error'] ?? "Failed to fetch collection history.";
      emit(HistoryError(errorMsg));
    } catch (e) {
      emit(const HistoryError("An unexpected error occurred."));
    }
  }
}