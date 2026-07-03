import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../Local/offline_user.dart';
import '../../Services/auth_service.dart';
import 'beneficiary_state.dart';

class BeneficiaryCubit extends Cubit<BeneficiaryState> {
  final AuthService authService;
  final OfflineUser offlineUser = OfflineUser();

  BeneficiaryCubit(this.authService) : super(BeneficiaryInitial());

  /// ============================================
  /// LOAD PROFILE
  /// ============================================
  Future<void> loadProfile() async {
    emit(BeneficiaryLoading());

    try {
      // ONLINE
      final profile = await authService.getUserProfile();

      emit(BeneficiaryLoaded(profile));
    } on DioException catch (_) {
      // OFFLINE
      try {
        final user = await offlineUser.getLastCachedUser();

        if (user != null) {
          emit(BeneficiaryLoaded(user));
          return;
        }

        emit(const BeneficiaryFailure("No offline profile found."));
      } catch (e) {
        emit(BeneficiaryFailure(e.toString()));
      }
    } catch (e) {
      emit(BeneficiaryFailure(e.toString()));
    }
  }

  /// ============================================
  /// REFRESH PROFILE
  /// ============================================
  Future<void> refreshProfile() async {
    await loadProfile();
  }
}
