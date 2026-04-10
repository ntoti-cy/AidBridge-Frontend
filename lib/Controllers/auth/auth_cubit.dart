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

  //REGISTER 
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
//Check network before registering
final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.none) {
  emit(AuthFailure(
    generalError: "You must be online to register for the first time",
  ));
  return;
}

      // Try backend registration
      final response = await authService.register(
        firstName: firstName,
        secondName: secondName,
        nationalId: nationalId,
        contact: contact,
        email: email,
        password: password,
      );


// Save offline in case of future login without connectivity
await _localRepo.insertUser(
  firstName: firstName,
  secondName: secondName, 
  nationalId: nationalId,
  contact: contact,
  email: email,
  password: password,
);
  
   emit(AuthRegistered(response));
  } on DioException catch (e) {
    emit(AuthFailure(
      generalError: e.message ?? "Registration failed. Try again.",
    ));
  } catch (e) {
    emit(AuthFailure(generalError: "Unexpected error: $e"));
  }
}


//LOGIN 
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      // Try backend login
      final token = await authService.login(email: email, password: password);

      // Fetch the user profile data using the new token
      final userData = await authService.getUserProfile(token);
      emit(AuthSuccess(token, data: userData));
    } catch (_) {
      // Fallback offline login
      final localUser = await _localRepo.getUserByEmailAndPassword(email, password);

      if (localUser != null) {
        emit(AuthSuccess("OFFLINE_TOKEN", data: localUser)); // Offline login
      } else {
        emit(AuthFailure(generalError: "Login failed. Check credentials."));
      }
    }
  }


 // SYNC OFFLINE USERS
  Future<void> syncOfflineUsers() async {
    try {
      emit(AuthSyncing()); // New state for syncing

      final offlineUsers = await _localRepo.getUnsyncedUsers();

      for (var user in offlineUsers) {
        try {
          await authService.register(
            firstName: user['first_name'],
            secondName: user['second_name'],
            nationalId: user['national_id'],
            contact: user['contact'],
            email: user['email'],
            password: user['password'],
          );
          await _localRepo.markUserAsSynced(user['email']);
        } catch (_) {
          // skip user, will retry next time
        }
      }
        

    } catch (_) {
      // overall sync failure can be ignored or logged
    }
  }


  // CLEAR FIELD ERRORS
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