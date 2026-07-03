import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:aid_bridge/Controllers/help/db_helper.dart'; // Import your DBHelper

part 'offline_state.dart';

class OfflineCubit extends Cubit<OfflineState> {
   final DBHelper dbHelper = DBHelper(); 

  OfflineCubit() : super(OfflineInitial());

  Future<void> verifyCode(String inputCode) async {
    emit(OfflineLoading());

  
    final code = await dbHelper.getCode(inputCode);

    if (code == null) {
      emit(OfflineInvalid("Code not found"));
    } else if (code['used'] == 1) {
      emit(OfflineAlreadyUsed("Code already used"));
    } else {
      
      await dbHelper.markCodeUsed(inputCode);
      emit(OfflineValid("Access granted"));
    }
  }
}