import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:aid_bridge/Models/beneficiary_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Services/auth_service.dart';
import 'officer_state.dart';

class OfficerCubit extends Cubit<OfficerState> {
  final AuthService authService;
  final DBHelper db = DBHelper();

  OfficerCubit(this.authService) : super(OfficerInitial());

  // Load Officer Dashboard
  Future<void> loadDashboard() async {
    emit(OfficerLoading());

    try {
      final officer = await authService.getUserProfile();

      final beneficiaries = await authService.downloadBeneficiaries();

      final activity = await authService.recentActivity();

      final List list = beneficiaries["beneficiaries"] ?? [];

      final servedToday = list.where((e) => e["token_status"] == "used").length;

      final remainingAid = list
          .where((e) => e["token_status"] == "active")
          .length;

      emit(
        OfficerLoaded(
          officer: officer,

          servedToday: servedToday,

          remainingAid: remainingAid,

          pendingSync: 0,

          lastSync: DateTime.now().toString().substring(11, 16),

          recentActivity: activity,
        ),
      );
    } on DioException catch (e) {
      emit(
        OfficerFailure(
          e.response?.data["error"] ?? "Unable to load dashboard.",
        ),
      );
    } catch (e) {
      emit(const OfficerFailure("Unable to load dashboard."));
    }
  }

  //Verify beneficiary Token
  Future<void> verifyToken(String aidToken) async {
    emit(TokenVerificationLoading());

    try {
      final response = await authService.verifyToken(aidToken);

      final beneficiary = response["beneficiary"];

      if (beneficiary == null) {
        emit(const OfficerActionFailure("Beneficiary information missing."));

        return;
      }

      emit(TokenVerified(Map<String, dynamic>.from(beneficiary)));
    } on DioException catch (e) {
      emit(
        OfficerActionFailure(
          e.response?.data["error"] ?? "Verification failed.",
        ),
      );
    } catch (e) {
      emit(const OfficerActionFailure("Unable to verify token."));
    }
  }

  // Download Beneficiaries
  Future<void> downloadBeneficiaries() async {
    emit(OfficerLoading());

    try {
      final response = await authService.downloadBeneficiaries();

      final List beneficiaries = response["beneficiaries"] ?? [];

      // Convert JSON to Beneficiary objects
      final beneficiaryList = beneficiaries
          .map((e) => Beneficiary.fromJson(e))
          .toList();

      // Clear old records
      await db.clearBeneficiaries();

      print(response);
      print("Objects: ${beneficiaryList.length}");

      // Save new records
      await db.insertBeneficiaries(beneficiaryList);

      final saved = await db.getBeneficiaries();
      print("SQLite count: ${saved.length}");
      print("Saved beneficiaries: ${saved.length}");
      print(saved.map((e) => e.name).toList());

      emit(BeneficiariesDownloaded(beneficiaryList.length));
    } on DioException catch (e) {
      emit(
        OfficerActionFailure(e.response?.data["error"] ?? "Download failed."),
      );
    } catch (e) {
      emit(OfficerActionFailure(e.toString()));
    }
  }

  // Distribute Aid
  Future<void> distributeAid(String aidToken) async {
    emit(const AidDistributionLoading());

    try {
      await authService.collectAid(aidToken);

      emit(const AidDistributed());
    } on DioException catch (e) {
      emit(
        OfficerActionFailure(
          e.response?.data["error"] ?? "Distribution failed.",
        ),
      );
    } catch (e) {
      emit(const OfficerActionFailure("Unable to distribute aid."));
    }
  }

  //Offline Synchronization
  Future<void> synchronize() async {
    emit(OfficerLoading());

    try {
      // Future:
      // Sync local SQLite records
      // with backend server

      emit(const OfficerSyncSuccess(0));
    } catch (e) {
      emit(const OfficerActionFailure("Synchronization failed."));
    }
  }

  // Start Distribution Session
  Future<void> startSession(String? expiryTime) async {
    try {
      await authService.dio.post(
        '/api/officer/start-distribution-session',
        data: expiryTime != null ? {"expiry_time": expiryTime} : {},
      );
      loadDashboard();
    } on DioException catch (e) {
      emit(
        OfficerActionFailure(
          e.response?.data["error"] ?? "Failed to start session.",
        ),
      );
    } catch (_) {
      emit(const OfficerActionFailure("Unable to start session."));
    }
  }

  // End Distribution Session
  Future<void> endSession(int sessionId) async {
    try {
      await authService.dio.post(
        '/api/officer/end-distribution-session/$sessionId',
      );
      loadDashboard();
    } on DioException catch (e) {
      emit(
        OfficerActionFailure(
          e.response?.data["error"] ?? "Failed to end session.",
        ),
      );
    } catch (_) {
      emit(const OfficerActionFailure("Unable to end session."));
    }
  }
}
