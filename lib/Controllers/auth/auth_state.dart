import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial
class AuthInitial extends AuthState {}

// Loading
class AuthLoading extends AuthState {}

class AuthSyncing extends AuthState {}

// Login Success
class AuthSuccess extends AuthState {
  final String token;
  final Map<String, dynamic>? data;

  const AuthSuccess(this.token, {this.data = const {}});

  @override
  List<Object?> get props => [token, data];
}

// Register Success
class AuthRegistered extends AuthState {
  final Map<String, dynamic> data;

  const AuthRegistered(this.data);

  @override
  List<Object?> get props => [data];
}

// Profile Completion
class ProfileCompleted extends AuthState {
  const ProfileCompleted();
}

class ProfileSavedOffline extends AuthState {
  const ProfileSavedOffline();
}

// Password
class PasswordChanged extends AuthState {
  const PasswordChanged();
}

// Failure
class AuthFailure extends AuthState {
  final String? generalError;
  final Map<String, List<String>> fieldErrors;

  const AuthFailure({
    this.generalError,
    this.fieldErrors = const {}, // Default to empty map
  });

  @override
  List<Object?> get props => [generalError, fieldErrors];
}
