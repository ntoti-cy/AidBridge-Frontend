import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../../Services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthInitial());

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final token = await authService.login(
        email: email,
        password: password,
      );

      emit(AuthSuccess(token));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // REGISTER
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final user = await authService.register(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthRegistered(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void logout() {
    emit(AuthInitial());
  }
}
