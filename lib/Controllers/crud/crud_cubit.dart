import 'package:aid_bridge/Controllers/auth/auth_state.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CrudCubit extends Cubit<AuthState> {
  final AuthService authService;

  CrudCubit(this.authService) : super(AuthInitial());

  // =====================================================
  // COMPLETE PROFILE
  // =====================================================

  Future<void> completeProfile(Map<String, dynamic> data) async {
    emit(AuthLoading());

    try {
      await authService.completeProfile(data);

      emit(const ProfileCompleted());
    } on DioException catch (e) {
      emit(
        AuthFailure(
          generalError:
              e.response?.data["error"] ?? "Unable to complete profile.",
        ),
      );
    } on Exception catch (e) {
      if (e.toString().contains("PROFILE_SAVED_OFFLINE")) {
        emit(const ProfileSavedOffline());
        return;
      }

      emit(AuthFailure(generalError: e.toString()));
    } catch (_) {
      emit(
        const AuthFailure(
          generalError: "Something went wrong. Please try again.",
        ),
      );
    }
  }

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(AuthLoading());

    try {
      await authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      emit(const PasswordChanged());
    } on DioException catch (e) {
      emit(
        AuthFailure(
          generalError:
              e.response?.data["error"] ?? "Unable to change password.",
        ),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          generalError: "Something went wrong. Please try again.",
        ),
      );
    }
  }
}
