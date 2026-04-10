part of 'offline_cubit.dart';


abstract class OfflineState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OfflineInitial extends OfflineState {}

class OfflineLoading extends OfflineState {}

class OfflineValid extends OfflineState {
  final String message;
  OfflineValid(this.message);

  @override
  List<Object?> get props => [message];
}

class OfflineInvalid extends OfflineState {
  final String message;
  OfflineInvalid(this.message);

  @override
  List<Object?> get props => [message];
}

class OfflineAlreadyUsed extends OfflineState {
  final String message;
  OfflineAlreadyUsed(this.message);

  @override
  List<Object?> get props => [message];
}