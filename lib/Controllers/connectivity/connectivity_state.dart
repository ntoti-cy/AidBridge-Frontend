import 'package:equatable/equatable.dart';

class ConnectivityState extends Equatable {
  final bool isOnline;

  const ConnectivityState({required this.isOnline});

  bool get isOffline => !isOnline;

  ConnectivityState copyWith({bool? isOnline}) {
    return ConnectivityState(isOnline: isOnline ?? this.isOnline);
  }

  @override
  List<Object> get props => [isOnline];
}
