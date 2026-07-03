import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// ===============================
/// INITIAL
/// ===============================

class AuthInitial extends AuthState {}

/// ===============================
/// LOADING
/// ===============================

class AuthLoading extends AuthState {}

class AuthSyncing extends AuthState {}



/// ===============================
/// LOGIN SUCCESS
/// ===============================

class AuthSuccess extends AuthState {
  final String token;
  final Map<String, dynamic>? data;

  const AuthSuccess(
    this.token, {
    this.data = const {},
  });

  @override
  List<Object?> get props => [
        token,
        data,
      ];
}

/// ===============================
/// REGISTER SUCCESS
/// ===============================

class AuthRegistered extends AuthState {
  final Map<String, dynamic> data;

  const AuthRegistered(this.data);

  @override
  List<Object?> get props => [data];
}

/// ===============================
/// PROFILE COMPLETION
/// ===============================

class ProfileCompleted extends AuthState {
  const ProfileCompleted();
}

class ProfileSavedOffline extends AuthState {
  const ProfileSavedOffline();
}

/// ===============================
/// PASSWORD
/// ===============================

class PasswordChanged extends AuthState {
  const PasswordChanged();
}

/// ===============================
/// FAILURE
/// ===============================

class AuthFailure extends AuthState {
  final Map<String, List<String>> fieldErrors;
  final String? generalError;

  const AuthFailure({
    this.fieldErrors = const {},
    this.generalError,
  });

  @override
  List<Object?> get props => [
        fieldErrors,
        generalError,
      ];
}