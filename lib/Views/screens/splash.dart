import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService auth = AuthService();
  final OfflineUser offlineUser = OfflineUser();

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startup();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      final pendingProfiles = await offlineUser.getPendingProfiles();
      debugPrint("Pending profiles found: ${pendingProfiles.length}");

      if (pendingProfiles.isEmpty) {
        return;
      }

      for (final profile in pendingProfiles) {
        try {
          debugPrint("Syncing profile ID: ${profile["id"]}");
          await auth.completeProfile(profile);
          await offlineUser.deletePendingProfile(profile["id"]);
          debugPrint("Profile synced successfully.");
        } catch (e) {
          debugPrint("Failed to sync profile ${profile["id"]}: $e");
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
    final role = user["role"] ?? "beneficiary";

    if (role == "aid_worker") {
      final requiresPasswordChange = _parseBool(
        user["requires_password_change"],
      );

      if (requiresPasswordChange) {
        Get.offAllNamed(AppRoutes.changePassword);
        return;
      }

      Get.offAllNamed(AppRoutes.officerDashboard, arguments: user);
      return;
    }

    final isProfileComplete = _parseBool(
      user["is_profile_complete"],
      defaultValue: true,
    );

    if (!isProfileComplete) {
      Get.offAllNamed(AppRoutes.completeProfile);
      return;
    }

    Get.offAllNamed(AppRoutes.beneficiaryDashboard, arguments: user);
  }

  Future<void> _startup() async {
    debugPrint("========== SPLASH START ==========");

    try {
      await auth.init();
    } catch (e) {
      debugPrint("Auth init error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 700));

    if (auth.AccessToken == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      await _syncPendingProfiles();
      await _routeUser();
    } catch (e) {
      try {
        await auth.refreshAccessToken();
        await _syncPendingProfiles();
        await _routeUser();
      } catch (_) {
        await auth.clearAccessToken();
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        // Keeps the gradient and corner circles from AppBackground
        showDecorations: true,
        child: Stack(
          children: [
            /// Additional Decorative Sparkles (Unique to Splash Screen)
            Positioned(
              top: 170,
              right: 80,
              child: Icon(
                Icons.auto_awesome,
                color: primaryColor.withOpacity(.45),
                size: 20,
              ),
            ),
            Positioned(
              bottom: 220,
              left: 60,
              child: Icon(
                Icons.auto_awesome,
                color: primaryColor.withOpacity(.35),
                size: 16,
              ),
            ),
            Positioned(
              top: 240,
              left: 70,
              child: Icon(
                Icons.star,
                color: primaryColor.withOpacity(.25),
                size: 10,
              ),
            ),

            /// Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Logo + Glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Radial glow
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor.withOpacity(.16),
                                primaryColor.withOpacity(.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        /// Animated logo
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(.95),
                              border: Border.all(
                                color: primaryColor.withOpacity(.12),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(.20),
                                  blurRadius: 45,
                                  spreadRadius: 6,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage(
                                  "lib/Assets/images/aidbridge_logo.png",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      "AIDBRIDGE",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Bridging Aid to the Last Mile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade600,
                        letterSpacing: .6,
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: const LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: Color(0xFFD8E6FF),
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
