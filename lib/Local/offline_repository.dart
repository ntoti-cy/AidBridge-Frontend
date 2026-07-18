import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:aid_bridge/Models/beneficiary_model.dart';

class OfflineRepository {
  final DBHelper db = DBHelper();

  // CODE OPERATIONS
  Future<Map<String, dynamic>?> getCode(String code) {
    return db.getCode(code);
  }

  Future<void> markCodeUsed(String code) {
    return db.markCodeUsed(code);
  }

  // BENEFICIARY OPERATIONS
  Future<Beneficiary?> findBeneficiary(String token) {
    return db.getBeneficiaryByToken(token);
  }

  Future<bool> canCollect(String token) {
    return db.canCollectAid(token);
  }

  Future<void> collectAid({
    required String aidToken,
    required int beneficiaryId,
    required int officerId,
    required int sessionId,
    required String center,
  }) {
    return db.collectAidOffline(
      aidToken: aidToken,
      beneficiaryId: beneficiaryId,
      officerId: officerId,
      distributionCenter: center,
      distributionSessionId: sessionId,
    );
  }

  // PENDING SYNC
  Future<List<Map<String, dynamic>>> pendingSync() {
    return db.getPendingSync();
  }

  Future<int> pendingSyncCount() {
    return db.getPendingSyncCount();
  }

  // HISTORY
  Future<List<Map<String, dynamic>>> getHistory() {
    return db.getHistory();
  }

  // STATISTICS
  Future<int> totalBeneficiaries() {
    return db.getTotalBeneficiaries();
  }

  Future<int> activeBeneficiaries() {
    return db.getActiveBeneficiaryCount();
  }

  Future<int> usedBeneficiaries() {
    return db.getUsedBeneficiaryCount();
  }

  Future<int> expiredBeneficiaries() {
    return db.getExpiredBeneficiaryCount();
  }

  Future<int> remainingBeneficiaries() {
    return db.getRemainingBeneficiaries();
  }

  Future<int> offlineCollectionsCount() {
    return db.getOfflineCollectionsCount();
  }

  Future<double> distributionProgress() {
    return db.getDistributionProgress();
  }

  // OFFLINE COLLECTIONS
  Future<List<Map<String, dynamic>>> offlineCollections() {
    return db.getOfflineCollections();
  }

  Future<List<Map<String, dynamic>>> unsyncedCollections() {
    return db.getUnsyncedCollections();
  }

  Future<bool> hasUnsyncedCollections() {
    return db.hasUnsyncedCollections();
  }

  // CLEANUP
  Future<void> clearOfflineData() {
    return db.clearOfficerOfflineData();
  }

  Future<Map<String, dynamic>?> currentUser() {
    return db.getLastUser();
  }

  Future<List<Map<String, dynamic>>> tokens() async {
    final data = await db.getTokens();

    return data.map((e) => e.toMap()).toList();
  }
}
