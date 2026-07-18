import 'package:aid_bridge/Local/offline_repository.dart';
import 'package:aid_bridge/Models/beneficiary_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'offline_state.dart';

class OfflineCubit extends Cubit<OfflineState> {
  final OfflineRepository repository;

  OfflineCubit(this.repository) : super(OfflineInitial());

  Future<void> verifyCode(String inputCode) async {
    emit(OfflineLoading());

    try {
      final code = await repository.getCode(inputCode);

      if (code == null) {
        emit(OfflineInvalid("Code not found"));
      } else if (code['used'] == 1) {
        emit(OfflineAlreadyUsed("Code already used"));
      } else {
        await repository.markCodeUsed(inputCode);
        emit(OfflineValid("Access granted"));
      }
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> verifyBeneficiary(String token) async {
    emit(OfflineLoading());

    try {
      final beneficiary = await repository.findBeneficiary(token);

      if (beneficiary == null) {
        emit(OfflineFailure("Beneficiary not found"));
        return;
      }

      final canCollect = await repository.canCollect(token);

      if (!canCollect) {
        emit(OfflineFailure("Aid already collected"));
        return;
      }

      emit(BeneficiaryVerified(beneficiary));
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> collectAid({
    required String aidToken,
    required int beneficiaryId,
    required int officerId,
    required int sessionId,
    required String center,
  }) async {
    emit(OfflineLoading());

    try {
      await repository.collectAid(
        aidToken: aidToken,
        beneficiaryId: beneficiaryId,
        officerId: officerId,
        sessionId: sessionId,
        center: center,
      );

      final stats = {
        "total": await repository.totalBeneficiaries(),
        "served": await repository.usedBeneficiaries(),
        "remaining": await repository.remainingBeneficiaries(),
        "pending": await repository.pendingSyncCount(),
      };

      emit(AidCollectedOffline("Aid recorded successfully", stats));
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> loadStatistics() async {
    emit(OfflineLoading());

    try {
      final stats = {
        "total": await repository.totalBeneficiaries(),
        "served": await repository.usedBeneficiaries(),
        "remaining": await repository.remainingBeneficiaries(),
        "pending": await repository.pendingSyncCount(),
      };

      emit(OfflineStatisticsLoaded(stats));
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> loadHistory() async {
    emit(OfflineLoading());

    try {
      final history = await repository.getHistory();
      emit(OfflineHistoryLoaded(history));
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> loadPendingSync() async {
    emit(OfflineLoading());

    try {
      final pending = await repository.pendingSync();
      emit(PendingSyncLoaded(pending));
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> loadOfflineCollections() async {
    emit(OfflineLoading());

    try {
      final collections = await repository.offlineCollections();
      emit(OfflineCollectionsLoaded(collections));
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> clearOfflineData() async {
    emit(OfflineLoading());

    try {
      await repository.clearOfflineData();
      emit(OfflineDataCleared());
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }

  Future<void> loadBeneficiaryDashboard() async {
    emit(OfflineLoading());

    try {
      final user = await repository.currentUser();
      final tokens = await repository.tokens();
      final history = await repository.getHistory();
      final pending = await repository.pendingSyncCount();

      final mergedUser = Map<String, dynamic>.from(user ?? {});

      final userCenter = mergedUser["distribution_center"]?.toString() ?? "";
      if (userCenter.isEmpty && tokens.isNotEmpty) {
        mergedUser["distribution_center"] = tokens.first["center_name"];
      }
      emit(
        OfflineBeneficiaryLoaded(
          user: mergedUser,
          tokens: tokens,
          history: history,
          pendingSync: pending,
        ),
      );
    } catch (e) {
      emit(OfflineFailure(e.toString()));
    }
  }
}
