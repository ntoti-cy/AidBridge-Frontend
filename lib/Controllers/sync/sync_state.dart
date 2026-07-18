import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {
  final int synced;
  final int failed;
  final String message;

  const SyncSuccess({
    required this.synced,
    required this.failed,
    required this.message,
  });

  @override
  List<Object?> get props => [synced, failed, message];
}

class SyncFailure extends SyncState {
  final String message;

  const SyncFailure(this.message);

  @override
  List<Object?> get props => [message];
}
