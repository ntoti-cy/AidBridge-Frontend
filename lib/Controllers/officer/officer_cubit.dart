import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Services/auth_service.dart';
import 'officer_state.dart';

class OfficerCubit extends Cubit<OfficerState> {
  final AuthService authService;

  OfficerCubit(this.authService)
      : super(OfficerInitial());

  // =====================================================
  // DASHBOARD
  // =====================================================

  Future<void> loadDashboard() async {
    emit(OfficerLoading());

    try {
      final officer =
          await authService.getUserProfile();

      final beneficiaries =
          await authService.downloadBeneficiaries();

      final activity =
        await authService.recentActivity();

      final List list =
          beneficiaries["beneficiaries"] ?? [];

      final servedToday = list
          .where((e) => e["token_status"] == "used")
          .length;

      final remainingAid = list
          .where((e) => e["token_status"] == "active")
          .length;

      emit(
        OfficerLoaded(
          officer: officer,
          servedToday: servedToday,
          remainingAid: remainingAid,
          pendingSync: 0,
          lastSync: DateTime.now()
              .toString()
              .substring(11, 16),
          recentActivity: activity,
        ),
      );
    } on DioException catch (e) {
      emit(
        OfficerFailure(
          e.response?.data["error"] ??
              "Unable to load dashboard.",
        ),
      );
    } catch (_) {
      emit(
        const OfficerFailure(
          "Unable to load dashboard.",
        ),
      );
    }
  }

  // =====================================================
  // VERIFY TOKEN
  // =====================================================

  Future<void> verifyToken(
    String aidToken,
  ) async {
    emit(OfficerLoading());

    try {
      final response =
          await authService.verifyToken(
        aidToken,
      );

      emit(
        TokenVerified(
          response["beneficiary"],
        ),
      );
    } on DioException catch (e) {
      emit(
        OfficerFailure(
          e.response?.data["error"] ??
              "Verification failed.",
        ),
      );
    } catch (_) {
      emit(
        const OfficerFailure(
          "Unable to verify token.",
        ),
      );
    }
  }

  // =====================================================
  // DOWNLOAD BENEFICIARIES
  // =====================================================

  Future<void> downloadBeneficiaries() async {
    emit(OfficerLoading());

    try {
      final response =
          await authService.downloadBeneficiaries();

      emit(
        BeneficiariesDownloaded(
          (response["beneficiaries"] as List)
              .length,
        ),
      );
    } on DioException catch (e) {
      emit(
        OfficerFailure(
          e.response?.data["error"] ??
              "Download failed.",
        ),
      );
    } catch (_) {
      emit(
        const OfficerFailure(
          "Unable to download beneficiaries.",
        ),
      );
    }
  }

  // =====================================================
  // COLLECT AID
  // =====================================================

  Future<void> distributeAid(
    String aidToken,
  ) async {
    emit(
      const AidDistributionLoading(),
    );

    try {
      await authService.collectAid(
        aidToken,
      );

      emit(
        const AidDistributed(),
      );
    } on DioException catch (e) {
      emit(
        OfficerFailure(
          e.response?.data["error"] ??
              "Distribution failed.",
        ),
      );
    } catch (_) {
      emit(
        const OfficerFailure(
          "Unable to distribute aid.",
        ),
      );
    }
  }

  // =====================================================
  // OFFLINE SYNC
  // =====================================================

  Future<void> synchronize() async {
    emit(OfficerLoading());

    try {
      // Will connect to SyncCubit later

      emit(
        const OfficerSyncSuccess(0),
      );
    } catch (_) {
      emit(
        const OfficerFailure(
          "Synchronization failed.",
        ),
      );
    }
  }
}