import 'package:equatable/equatable.dart';

abstract class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TokenInitial extends TokenState {}

// Generating token
class TokenGenerating extends TokenState {}

// One-time event
// Used only to open QR screen
class TokenGenerated extends TokenState {
  final Map<String, dynamic> response;

  const TokenGenerated(this.response);

  @override
  List<Object?> get props => [response];
}

// Error
class TokenFailure extends TokenState {
  final String message;

  const TokenFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TokenLoading extends TokenState {}

class TokenDashboardLoaded extends TokenState {
  final Map<String, dynamic> status;
  final List<dynamic> history;

  const TokenDashboardLoaded({required this.status, required this.history});

  int get historyCount => history.length;

  @override
  List<Object?> get props => [status, history];
}
