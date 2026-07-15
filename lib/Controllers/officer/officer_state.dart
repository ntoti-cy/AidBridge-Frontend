import 'package:equatable/equatable.dart';

abstract class OfficerState extends Equatable {
  const OfficerState();

  @override
  List<Object?> get props => [];
}

/// Initial
class OfficerInitial extends OfficerState {}

/// Dashboard Loading
class OfficerLoading extends OfficerState {}

class SessionStarting extends OfficerState {}

class SessionEnding extends OfficerState {}

// Officer Dashboard Loaded
class OfficerLoaded extends OfficerState {
  final Map<String, dynamic> officer;

  final int servedToday;

  final int remainingAid;

  final int pendingSync;

  final String lastSync;

  final List recentActivity;

  const OfficerLoaded({
    required this.officer,
    required this.servedToday,
    required this.remainingAid,
    required this.pendingSync,
    required this.lastSync,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [
    officer,
    servedToday,
    remainingAid,
    pendingSync,
    lastSync,
    recentActivity,
  ];
}

// Token Verification
class TokenVerificationLoading extends OfficerState {}

// Beneficiary verified successfully
class TokenVerified extends OfficerState {
  final Map<String, dynamic> beneficiary;

  const TokenVerified(this.beneficiary);

  @override
  List<Object?> get props => [beneficiary];
}

// Aid Distribution
class AidDistributionLoading extends OfficerState {
  const AidDistributionLoading();
}

// Aid successfully distributed
class AidDistributed extends OfficerState {
  const AidDistributed();
}

// Beneficiary Download
class BeneficiariesDownloaded extends OfficerState {
  final int count;

  const BeneficiariesDownloaded(this.count);

  @override
  List<Object?> get props => [count];
}

// Offline Synchronization
class OfficerSyncSuccess extends OfficerState {
  final int synced;

  const OfficerSyncSuccess(this.synced);

  @override
  List<Object?> get props => [synced];
}

/// Error
class OfficerFailure extends OfficerState {
  final String message;

  const OfficerFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class OfficerActionFailure extends OfficerState {
  final String message;

  const OfficerActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
