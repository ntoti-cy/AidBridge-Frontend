import 'package:aid_bridge/Controllers/sync/sync_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncRepository repository;

  SyncCubit(this.repository) : super(SyncInitial());

  Future<void> synchronize() async {
    emit(SyncLoading());

    try {
      final result = await repository.synchronize();

      emit(
        SyncSuccess(
          synced: result["synced"],
          failed: result["failed"],
          message: result["message"],
        ),
      );
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  void reset() {
    emit(SyncInitial());
  }
}
