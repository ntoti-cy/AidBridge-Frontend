import 'dart:async';

import 'package:aid_bridge/Controllers/connectivity/connectivity_state.dart';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit() : super(const ConnectivityState(isOnline: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    final result = await _connectivity.checkConnectivity();

    _updateConnection(result);

    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnection,
    );
  }

  void _updateConnection(List<ConnectivityResult> results) {
    final online = !results.contains(ConnectivityResult.none);

    emit(state.copyWith(isOnline: online));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
