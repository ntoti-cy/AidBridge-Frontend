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
        emit(const AuthFailure(
          generalError: "You must be connected to the internet to register a new account.",
        ));
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
      emit(AuthFailure(generalError: e.response?.data['error']?.toString() ?? "Registration failed. Try again."));
    } catch (e) {
      emit(AuthFailure(generalError: "Unexpected error: $e"));
    }
  }


  // LOGIN 
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      // 1. Try backend login first (Online)
      final token = await authService.login(email: email, password: password);
      final userData = await authService.getUserProfile(token);

      // 2. Save/Update locally so they can log in offline tomorrow
      await _localRepo.insertUser(
        firstName: userData['first_name']?.toString() ?? '',
        secondName: userData['second_name']?.toString() ?? '',
        nationalId: userData['national_id']?.toString() ?? '',
        contact: userData['contact']?.toString() ?? '',
        email: email,
        password: password, // Store password to verify offline late
        role: userData['role']?.toString() ?? 'beneficiary',
      );

      emit(AuthSuccess(token, data: userData));

    } catch (e) {
      // 3. If online login fails 
      print("Online login failed, attempting offline fallback: $e");
      
      final localUser = await _localRepo.getUserByEmailAndPassword(email, password);

      if (localUser != null) {
        // Success! Provide a dummy token and the local SQLite data
        emit(AuthSuccess("OFFLINE_TOKEN", data: localUser)); 
      } else {
        // Failed offline too (wrong password or user never logged in while online before)
        emit(const AuthFailure(generalError: "Login failed. Check your credentials or connect to the internet."));
      }
    }
  }

  // --- CLEAR FIELD ERRORS ---
  void clearFieldError(String field) {
    if (state is AuthFailure) {
      final currentState = state as AuthFailure;
      final updatedErrors = Map<String, List<String>>.from(currentState.fieldErrors);
      updatedErrors.remove(field);

      emit(AuthFailure(
        fieldErrors: updatedErrors,
        generalError: currentState.generalError,
      ));
    }
  }
}