import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSyncing extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final Map<String, dynamic>? data; 

  const AuthSuccess(this.token, {this.data = const {}});

  @override
  List<Object?> get props => [token, data];
}

class AuthRegistered extends AuthState {
  final Map<String, dynamic> data;

  const AuthRegistered(this.data );

  @override
  List<Object?> get props => [data];
}

class AuthFailure extends AuthState {
  final Map<String, List<String>> fieldErrors;
  final String? generalError;

  const AuthFailure({
    this.fieldErrors = const {},
    this.generalError,
  });
}

