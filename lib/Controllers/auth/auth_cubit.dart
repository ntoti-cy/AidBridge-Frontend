import 'package:flutter_bloc/flutter_bloc.dart';
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
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // LOGIN (leave as is for now)
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final token =
          await authService.login(email: email, password: password);

      emit(AuthSuccess(token));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
