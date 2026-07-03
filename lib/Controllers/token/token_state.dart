import 'package:equatable/equatable.dart';

abstract class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object?> get props => [];
}

/// Initial
class TokenInitial extends TokenState {}

/// Loading
class TokenLoading extends TokenState {}

/// Token generated successfully
class TokenGenerated extends TokenState {
  final Map<String, dynamic> token;

  const TokenGenerated(this.token);

  @override
  List<Object?> get props => [token];
}

/// History loaded
class TokenHistoryLoaded extends TokenState {
  final List<dynamic> history;

  const TokenHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

/// Error
class TokenFailure extends TokenState {
  final String message;

  const TokenFailure(this.message);

  @override
  List<Object?> get props => [message];
}