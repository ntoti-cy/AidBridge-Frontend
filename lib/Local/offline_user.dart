import 'dart:convert';

import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:crypto/crypto.dart';

class OfflineUser {
  final DBHelper _db = DBHelper();

  // =====================================================
  // PASSWORD HASHING
  // =====================================================

  static String _generateSalt(String email) {
    final bytes = utf8.encode("aidBridge_salt_$email");
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  // =====================================================
  // SAVE USER AFTER ONLINE LOGIN
  // =====================================================

  Future<bool> insertUser({
    required String firstName,
    required String secondName,
    required String nationalId,
    required String contact,
    required String email,
    required String password,
    required String role,
    required bool requiresPasswordChange,
    required bool isProfileComplete,
  }) async {
    try {
      final salt = _generateSalt(email);
      final hash = _hashPassword(password, salt);

      await _db.upsertUser({
        "first_name": firstName,
        "second_name": secondName,
        "national_id": nationalId,
        "contact": contact,
        "email": email,
        "password_hash": "$salt:$hash",
        "role": role,
        "requires_password_change": requiresPasswordChange ? 1 : 0,
        "is_profile_complete": isProfileComplete ? 1 : 0,
        "synced": 1,
      });

      return true;
    } catch (e) {
      print("Offline cache failed: $e");
      return false;
    }
  }

  // =====================================================
  // OFFLINE LOGIN
  // =====================================================

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final row = await _db.getUserByEmail(email);

      if (row == null) return null;

      final storedHash = row["password_hash"]?.toString() ?? "";

      if (!storedHash.contains(":")) return null;

      final parts = storedHash.split(":");

      if (parts.length != 2) return null;

      final salt = parts[0];
      final savedHash = parts[1];

      final enteredHash = _hashPassword(password, salt);

      if (enteredHash != savedHash) {
        return null;
      }

      return {
        "first_name": row["first_name"],
        "second_name": row["second_name"],
        "national_id": row["national_id"],
        "contact": row["contact"],
        "email": row["email"],
        "role": row["role"],
        "requires_password_change": row["requires_password_change"] == 1,
        "is_profile_complete": row["is_profile_complete"] == 1,
      };
    } catch (e) {
      print("Offline login failed: $e");
      return null;
    }
  }

  // =====================================================
  // GET USER BY EMAIL
  // =====================================================

  Future<Map<String, dynamic>?> getUser(String email) async {
    try {
      return await _db.getUserByEmail(email);
    } catch (e) {
      print("Failed to get user: $e");
      return null;
    }
  }

  // =====================================================
  // GET LAST CACHED USER
  // =====================================================

  Future<Map<String, dynamic>?> getLastCachedUser() async {
    try {
      return await _db.getLastUser();
    } catch (e) {
      print("Failed to get last cached user: $e");
      return null;
    }
  }

  // =====================================================
  // UPDATE USER
  // =====================================================

  Future<void> updateUser({
    required String email,
    required Map<String, dynamic> values,
  }) async {
    try {
      await _db.updateUser(email, values);
    } catch (e) {
      print("Failed to update cached user: $e");
    }
  }

  // =====================================================
  // DELETE USER
  // =====================================================

  Future<void> deleteUser(String email) async {
    try {
      await _db.deleteUser(email);
    } catch (e) {
      print("Failed to delete cached user: $e");
    }
  }

  // =====================================================
  // MARK USER AS SYNCED
  // =====================================================

  Future<void> markUserAsSynced(String email) async {
    try {
      await _db.markUserSynced(email);
    } catch (e) {
      print("Failed to mark synced: $e");
    }
  }

  // =====================================================
  // CHECK USER EXISTS
  // =====================================================

  Future<bool> userExists(String email) async {
    try {
      final user = await _db.getUserByEmail(email);
      return user != null;
    } catch (e) {
      print("Failed to check user existence: $e");
      return false;
    }
  }

  // =====================================================
  // CACHE PROFILE
  // =====================================================

  Future<void> cacheProfile(Map<String, dynamic> profile) async {
    try {
      final email = profile["email"]?.toString() ?? "";
      if (email.isEmpty) return;

      final existing = await _db.getUserByEmail(email);

      final values = {
        "first_name": profile["first_name"],
        "second_name": profile["second_name"],
        "national_id": profile["national_id"]?.toString(),
        "contact": profile["contact"],
        "email": email,
        "role": profile["role"] ?? existing?["role"] ?? "beneficiary",
        "distribution_center":
            profile["distribution_center"] ??
            existing?["distribution_center"] ??
            "",
        "requires_password_change": existing?["requires_password_change"] ?? 0,
        "is_profile_complete": 1,
        "synced": 1,
        // never overwrite the real password hash with nothing
        "password_hash": existing?["password_hash"] ?? "",
      };

      print("DEBUG: cacheProfile values = $values");

      if (existing != null) {
        await _db.updateUser(email, values);
      } else {
        await _db.upsertUser(values);
      }
    } catch (e) {
      print("Failed to cache profile: $e");
    }
  }

  // =====================================================
  // SAVE HISTORY
  // =====================================================

  Future<void> saveHistory(List<Map<String, dynamic>> history) async {
    try {
      await _db.saveHistory(history);
    } catch (e) {
      print("Failed to save history: $e");
    }
  }

  // =====================================================
  // GET HISTORY
  // =====================================================

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      return await _db.getHistory();
    } catch (e) {
      print("Failed to load history: $e");
      return [];
    }
  }

  // =====================================================
  // SAVE PENDING PROFILE
  // =====================================================

  Future<void> savePendingProfile(Map<String, dynamic> profile) async {
    try {
      await _db.savePendingProfile(profile);
    } catch (e) {
      print("Failed to save pending profile: $e");
    }
  }

  // =====================================================
  // GET PENDING PROFILES
  // =====================================================

  Future<List<Map<String, dynamic>>> getPendingProfiles() async {
    try {
      final profile = await _db.getPendingProfile();
      return profile == null ? [] : [profile];
    } catch (e) {
      print("Failed to get pending profiles: $e");
      return [];
    }
  }

  // =====================================================
  // DELETE PENDING PROFILE
  // =====================================================

  Future<void> deletePendingProfile(int id) async {
    try {
      await _db.deletePendingProfile();
    } catch (e) {
      print("Failed to delete pending profile: $e");
    }
  }
}
