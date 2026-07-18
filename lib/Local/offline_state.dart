part of 'offline_cubit.dart';

abstract class OfflineState extends Equatable {
  const OfflineState();

  @override
  List<Object?> get props => [];
}

class OfflineInitial extends OfflineState {}

class OfflineLoading extends OfflineState {}

class OfflineValid extends OfflineState {
  final String message;

  const OfflineValid(this.message);

  @override
  List<Object?> get props => [message];
}

class OfflineInvalid extends OfflineState {
  final String message;

  const OfflineInvalid(this.message);

  @override
  List<Object?> get props => [message];
}

class OfflineAlreadyUsed extends OfflineState {
  final String message;

  const OfflineAlreadyUsed(this.message);

  @override
  List<Object?> get props => [message];
}

class OfflineFailure extends OfflineState {
  final String message;

  const OfflineFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BeneficiaryVerified extends OfflineState {
  final Beneficiary beneficiary;

  const BeneficiaryVerified(this.beneficiary);

  @override
  List<Object?> get props => [beneficiary];
}

class AidCollectedOffline extends OfflineState {
  final String message;

  /// Updated dashboard statistics after collection
  final Map<String, dynamic> statistics;

  const AidCollectedOffline(this.message, this.statistics);

  @override
  List<Object?> get props => [message, statistics];
}

class OfflineStatisticsLoaded extends OfflineState {
  final Map<String, dynamic> stats;

  const OfflineStatisticsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class OfflineHistoryLoaded extends OfflineState {
  final List<Map<String, dynamic>> history;

  const OfflineHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class PendingSyncLoaded extends OfflineState {
  final List<Map<String, dynamic>> pendingItems;

  const PendingSyncLoaded(this.pendingItems);

  @override
  List<Object?> get props => [pendingItems];
}

class OfflineCollectionsLoaded extends OfflineState {
  final List<Map<String, dynamic>> collections;

  const OfflineCollectionsLoaded(this.collections);

  @override
  List<Object?> get props => [collections];
}

class OfflineDataCleared extends OfflineState {
  const OfflineDataCleared();
}

class OfflineSyncComplete extends OfflineState {
  const OfflineSyncComplete();
}

class OfflineBeneficiaryLoaded extends OfflineState {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> tokens;
  final List<Map<String, dynamic>> history;
  final int pendingSync;

  const OfflineBeneficiaryLoaded({
    required this.user,
    required this.tokens,
    required this.history,
    required this.pendingSync,
  });

  @override
  List<Object?> get props => [user, tokens, history, pendingSync];
}
