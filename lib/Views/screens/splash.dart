import 'package:aid_bridge/Local/offline_user.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService auth = AuthService();
  final OfflineUser offlineUser = OfflineUser();

  @override
  void initState() {
    super.initState();
    _startup();
  }

  bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;

    if (value is bool) return value;

    if (value is int) return value == 1;

    if (value is String) {
      return value.toLowerCase() == "true" || value == "1";
    }

    return defaultValue;
  }

  Future<void> _syncPendingProfiles() async {
    try {
      debugPrint("Checking pending offline profiles...");

      final pendingProfiles =
          await offlineUser.getPendingProfiles();

      debugPrint(
          "Pending profiles found: ${pendingProfiles.length}");

      if (pendingProfiles.isEmpty) {
        return;
      }

      for (final profile in pendingProfiles) {
        try {
          debugPrint(
              "Syncing profile ID: ${profile["id"]}");

          await auth.completeProfile(profile);

          await offlineUser.deletePendingProfile(
            profile["id"],
          );

          debugPrint(
              "Profile synced successfully.");
        } catch (e) {
          debugPrint(
              "Failed to sync profile ${profile["id"]}: $e");
        }
      }
    } catch (e, stack) {
      debugPrint("Sync error: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _routeUser() async {
    debugPrint("Fetching logged in user...");

    final user = await auth.getUserProfile();

    debugPrint("User Profile:");
    debugPrint(user.toString());

    final role = user["role"] ?? "beneficiary";

    if (role == "aid_worker") {
      final requiresPasswordChange = _parseBool(
        user["requires_password_change"],
      );

      if (requiresPasswordChange) {
        debugPrint(
            "Officer must change password.");

        Get.offAllNamed(AppRoutes.changePassword);
        return;
      }

      debugPrint(
          "Navigating to Officer Dashboard.");

      Get.offAllNamed(
        AppRoutes.officerDashboard,
        arguments: user,
      );
      return;
    }

    final isProfileComplete = _parseBool(
      user["is_profile_complete"],
      defaultValue: true,
    );

    if (!isProfileComplete) {
      debugPrint(
          "Beneficiary profile incomplete.");

      Get.offAllNamed(
        AppRoutes.completeProfile,
      );
      return;
    }

    debugPrint(
        "Navigating to Beneficiary Dashboard.");

    Get.offAllNamed(
      AppRoutes.beneficiaryDashboard,
      arguments: user,
    );
  }

  Future<void> _startup() async {
  debugPrint("========== SPLASH START ==========");
  
  // 1. Give the UI thread a moment to render the initial frame
  await Future.delayed(const Duration(milliseconds: 500)); 

  // 2. Check for presence of token
  if (auth.AccessToken == null) {
    debugPrint("No access token found.");
    Get.offAllNamed(AppRoutes.login);
    return;
  }

  // 3. Attempt initial sync and routing
  try {
    debugPrint("Attempting primary sync and route...");
    await _syncPendingProfiles();
    await _routeUser();
    debugPrint("========== SPLASH COMPLETE (SUCCESS) ==========");
    return; // Exit after successful routing
  } catch (e) {
    debugPrint("Primary attempt failed: $e. Attempting token refresh...");
    
    // 4. If primary attempt fails, attempt recovery via refresh
    try {
      await auth.refreshAccessToken();
      debugPrint("Refresh successful.");
      
      await _syncPendingProfiles();
      await _routeUser();
      debugPrint("========== SPLASH COMPLETE (RECOVERED) ==========");
    } catch (refreshError) {
      debugPrint("Refresh failed: $refreshError");
      await auth.clearAccessToken();
      Get.offAllNamed(AppRoutes.login); // Only navigate to login if recovery fails
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}