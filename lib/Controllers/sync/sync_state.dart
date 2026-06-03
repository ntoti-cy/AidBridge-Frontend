import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {
  final int count;
  final String sessionName;

  const SyncSuccess(this.count, this.sessionName);

  @override
  List<Object?> get props => [count, sessionName];
}

class SyncFailure extends SyncState {
  final String error;

  const SyncFailure(this.error);

  @override
  List<Object?> get props => [error];
}