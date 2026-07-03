import 'package:equatable/equatable.dart';

abstract class OfficerState extends Equatable {
  const OfficerState();

  @override
  List<Object?> get props => [];
}

/// Initial
class OfficerInitial extends OfficerState {}

/// Loading
class OfficerLoading extends OfficerState {}

/// Dashboard Loaded
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

/// Token verified
class TokenVerified extends OfficerState {
  final Map<String, dynamic> beneficiary;

  const TokenVerified(this.beneficiary);

  @override
  List<Object?> get props => [beneficiary];
}

/// Beneficiaries downloaded
class BeneficiariesDownloaded extends OfficerState {
  final int count;

  const BeneficiariesDownloaded(this.count);

  @override
  List<Object?> get props => [count];
}

/// Aid Distribution Loading
class AidDistributionLoading extends OfficerState {
  const AidDistributionLoading();
}

/// Aid Distributed
class AidDistributed extends OfficerState {
  const AidDistributed();
}

/// Offline Sync Success
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