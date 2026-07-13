import 'package:equatable/equatable.dart';

abstract class BeneficiaryState extends Equatable {
  const BeneficiaryState();

  @override
  List<Object?> get props => [];
}

// Initial State
class BeneficiaryInitial extends BeneficiaryState {}

// Loading profile
class BeneficiaryLoading extends BeneficiaryState {}

// Profile successfully loaded
class BeneficiaryLoaded extends BeneficiaryState {
  final Map<String, dynamic> profile;

  const BeneficiaryLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

// syncing state
class BeneficiarySyncing extends BeneficiaryState {}

// Error state
class BeneficiaryFailure extends BeneficiaryState {
  final String message;

  const BeneficiaryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
