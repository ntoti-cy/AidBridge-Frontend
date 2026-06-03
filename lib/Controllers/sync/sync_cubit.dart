import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aid_bridge/Controllers/sync/sync_state.dart';
import 'package:aid_bridge/Controllers/sync/beneficiary_controller.dart';

class SyncCubit extends Cubit<SyncState> {
  final BeneficiaryController _controller = BeneficiaryController();

  SyncCubit() : super(SyncInitial());

  Future<void> syncData(String token) async {
    emit(SyncLoading());

    final result = await _controller.syncBeneficiaries(token);

    if (result['success'] == true) {
      emit(SyncSuccess(result['count'], result['session']));
    } else {
      emit(SyncFailure(result['error']));
    }
  }
  
  // Resets the state back to initial after a success/failure dialog is dismissed
  void resetState() {
    emit(SyncInitial());
  }
}