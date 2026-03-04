import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'auth_state.dart';
import '../../../Services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

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
      final Map<String, List<String>> extractedErrors = {};
      String? generalError;

      if (e.response?.data != null) {
        final responseData = e.response!.data;

        if (responseData["error"] != null) {
          responseData["error"].forEach((key, value) {
            if (value is List) {
              extractedErrors[key] = value.map((v) => v.toString()).toList();
            } else if (value is String) {
              extractedErrors[key] = [value];
            }
          });

          generalError = extractedErrors["general"]?.first;
        }
      } else {
        generalError = "Something went wrong";
      }

      emit(
        AuthFailure(fieldErrors: extractedErrors, generalError: generalError),
      );
    } catch (e) {
      emit(AuthFailure(generalError: "Unexpected error occurred"));
    }
  }

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    try {
      emit(AuthLoading());

      final token = await authService.login(email: email, password: password);

      emit(AuthSuccess(token));
    } on DioException catch (e) {
      final Map<String, List<String>> extractedErrors = {};
      String? generalError;

      if (e.response?.data != null) {
        final responseData = e.response!.data;

        if (responseData["error"] != null) {
          responseData["error"].forEach((key, value) {
            if (value is List) {
              extractedErrors[key] = value.map((v) => v.toString()).toList();
            } else if (value is String) {
              extractedErrors[key] = [value];
            }
          });

          generalError = extractedErrors["general"]?.first;
        }
      } else {
        generalError = "Something went wrong";
      }

      emit(
        AuthFailure(fieldErrors: extractedErrors, generalError: generalError),
      );
    } catch (e) {
      emit(AuthFailure(generalError: "Unexpected error occurred"));
    }
  }

  // Clear error for a specific field
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
}
