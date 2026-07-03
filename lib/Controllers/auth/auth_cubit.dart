import 'package:aid_bridge/Local/offline_user.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'auth_state.dart';
import '../../../Services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  final OfflineUser _localRepo = OfflineUser();

  AuthCubit(this.authService) : super(AuthInitial());

  // REGISTER
  Future<void> register({
    required String firstName,
    required String secondName,
    required String nationalId,
    required String contact,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      // 1. Check network before allowing registration
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(
          const AuthFailure(
            generalError:
                "You must be connected to the internet to register a new account.",
          ),
        );
        return; // Stop execution here
      }

      // 2. Backend registration (Only happens if online)
      final response = await authService.register(
        firstName: firstName,
        secondName: secondName,
        nationalId: nationalId,
        contact: contact,
        email: email,
        password: password,
      );

      emit(AuthRegistered(response));
    } on DioException catch (e) {
      emit(
        AuthFailure(
          generalError:
              e.response?.data['error']?.toString() ??
              "Registration failed. Try again.",
        ),
      );
    } catch (e) {
      emit(AuthFailure(generalError: "Unexpected error: $e"));
    }
  }

  // LOGIN

Future<void> login({
  required String email,
  required String password,
}) async {
  emit(AuthLoading());

  final connectivity =
      await Connectivity().checkConnectivity();

  final bool online =
      !connectivity.contains(ConnectivityResult.none);

  // ===========================
  // OFFLINE LOGIN
  // ===========================

  if (!online) {
    final localUser =
        await _localRepo.getUserByEmailAndPassword(
      email,
      password,
    );

    if (localUser != null) {
      emit(
        AuthSuccess(
          "OFFLINE_TOKEN",
          data: localUser,
        ),
      );
    } else {
      emit(
        const AuthFailure(
          generalError:
              "No internet connection and no offline account found.",
        ),
      );
    }

    return;
  }

  // ===========================
  // ONLINE LOGIN
  // ===========================

  try {
    final token = await authService.login(
      email: email,
      password: password,
    );

    final userData =
        await authService.getUserProfile();

    try {
      await _localRepo.insertUser(
        firstName:
            userData["first_name"]?.toString() ?? "",
        secondName:
            userData["second_name"]?.toString() ?? "",
        nationalId:
            userData["national_id"]?.toString() ?? "",
        contact:
            userData["contact"]?.toString() ?? "",
        email: email,
        password: password,
        role:
            userData["role"]?.toString() ??
                "beneficiary",
        requiresPasswordChange:
            _parseBool(
              userData[
                  "requires_password_change"],
            ),
        isProfileComplete:
            _parseBool(
              userData[
                  "is_profile_complete"],
              defaultVal: true,
            ),
      );
    } catch (_) {}

    emit(
      AuthSuccess(
        token,
        data: userData,
      ),
    );
  } on DioException catch (e) {
    _handleDioError(e);
  } catch (e) {
    emit(
      AuthFailure(
        generalError: e.toString(),
      ),
    );
  }
}
  //CLEAR FIELD ERRORS
  void clearFieldError(String field) {
    if (state is AuthFailure) {
      final currentState = state as AuthFailure;
      final updatedErrors = Map<String, List<String>>.from(
        currentState.fieldErrors,
      );
      updatedErrors.remove(field);

      emit(
        AuthFailure(
          fieldErrors: updatedErrors,
          generalError: currentState.generalError,
        ),
      );
    }
  }

  //HELPERS

  bool _parseBool(dynamic value, {bool defaultVal = false}) {
  if (value == null) return defaultVal;

  if (value is bool) return value;

  if (value is int) return value == 1;

  if (value is String) {
    return value.toLowerCase() == "true" || value == "1";
  }

  return defaultVal;
}

  void _handleDioError(DioException e) {
  final data = e.response?.data;

  if (data is Map<String, dynamic>) {
    // Validation errors
    if (data["error"] is Map<String, dynamic>) {
      final raw =
          data["error"] as Map<String, dynamic>;

      final errors = raw.map((key, value) {
        if (value is List) {
          return MapEntry(
            key,
            value.map((e) => e.toString()).toList(),
          );
        }

        return MapEntry(key, [value.toString()]);
      });

      emit(AuthFailure(fieldErrors: errors));
      return;
    }

    // Backend message
    if (data["error"] is String) {
      emit(
        AuthFailure(
          generalError: data["error"],
        ),
      );
      return;
    }

    if (data["message"] is String) {
      emit(
        AuthFailure(
          generalError: data["message"],
        ),
      );
      return;
    }
  }

  emit(
    AuthFailure(
      generalError:
          "Something went wrong. Please try again.",
    ),
  );
}
}