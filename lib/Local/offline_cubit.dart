import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'code_repo.dart';

part 'offline_state.dart';

class OfflineCubit extends Cubit<OfflineState> {
  final CodeRepo repo;

  OfflineCubit(this.repo) : super(OfflineInitial());

  Future<void> verifyCode(String inputCode) async {
    emit(OfflineLoading());

    final code = await repo.getCode(inputCode);

    if (code == null) {
      emit(OfflineInvalid("Code not found"));
    } else if (code['is_used'] == 1) {
      emit(OfflineAlreadyUsed("Code already used"));
    } else {
      await repo.markAsUsed(inputCode);
      emit(OfflineValid ("Access granted"));
    }
  }
}