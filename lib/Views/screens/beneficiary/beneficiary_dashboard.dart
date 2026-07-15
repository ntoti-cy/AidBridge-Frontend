import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/beneficiary/beneficiary_cubit.dart';
import 'package:aid_bridge/Controllers/beneficiary/beneficiary_state.dart';
import 'package:aid_bridge/Controllers/token/token_cubit.dart';
import 'package:aid_bridge/Controllers/token/token_state.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BeneficiaryDashboard extends StatefulWidget {
  const BeneficiaryDashboard({super.key});

  @override
  State<BeneficiaryDashboard> createState() => _BeneficiaryDashboardState();
}

class _BeneficiaryDashboardState extends State<BeneficiaryDashboard> {
  String centerName = "";
  String tokenStatus = "";
  bool hasToken = false;
  int collectionCount = 0;
  bool navigatingToQr = false;
  String? currentActiveToken; // Store token locally once loaded
  String? currentExpiryTime;

  @override
  void initState() {
    super.initState();
    context.read<BeneficiaryCubit>().loadProfile();
    context.read<TokenCubit>().loadDashboard();
  }

  Future<void> _refresh() async {
    await context.read<BeneficiaryCubit>().refreshProfile();
    await context.read<TokenCubit>().loadDashboard();
  }

  Future<void> _logout() async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: errorColor),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          ),
          content: const Text(
            "Are you sure you want to sign out of AidBridge?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: errorColor),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (logout == true) {
      await AuthService().logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Manage Account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: primaryColor,
                    ),
                  ),
                  title: const Text(
                    "View Profile",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "View your personal information",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: textSecondaryColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.beneficiaryProfile);
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_outline, color: Colors.orange),
                  ),
                  title: const Text(
                    "Change Password",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Update your account password",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: textSecondaryColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.changePassword);
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    "Sign out of AidBridge",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.red,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateToken() async {
    await context.read<TokenCubit>().requestToken();
  }

  Future<void> _openQrCode(String token, {String? expiryTime}) async {
    if (navigatingToQr) return;
    navigatingToQr = true;
    await Get.toNamed(
      AppRoutes.qrcode,
      arguments: {"aid_token": token, "expiry_time": expiryTime},
    );
    if (!mounted) return;
    navigatingToQr = false;
    context.read<TokenCubit>().loadDashboard();
  }

  void _openTokenStatus() {
    Get.toNamed(AppRoutes.tokens);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: primaryColor,
          child: MultiBlocListener(
            listeners: [
              BlocListener<TokenCubit, TokenState>(
                listener: (context, state) {
                  if (state is TokenGenerated) {
                    final token = state.response["aid_token"]?.toString();
                    final expiryTime = state.response["expiry_time"]
                        ?.toString();
                    if (token != null && token.isNotEmpty) {
                      setState(() {
                        currentActiveToken = token;
                        currentExpiryTime = expiryTime;
                        hasToken = true;
                      });
                      _openQrCode(token, expiryTime: expiryTime);
                    }
                  }
                  if (state is TokenDashboardLoaded) {
                    final data = state.status;
                    setState(() {
                      hasToken = data["has_token"] == true;
                      centerName = data["center_name"]?.toString() ?? "";
                      tokenStatus = data["token_status"]?.toString() ?? "";
                      currentActiveToken = data["aid_token"]?.toString();
                      currentExpiryTime = data["expiry_time"]?.toString();
                      collectionCount = state.history.length;
                    });
                  }
                  if (state is TokenFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: errorColor,
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const SizedBox(height: 20),
                _buildWelcomeBanner(),
                const SizedBox(height: 24),
                _buildAidStatusCard(),
                const SizedBox(height: 24),
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 14),
                _buildInteractiveActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        String displayName = "Beneficiary";
        if (state is BeneficiaryLoaded) {
          displayName = state.profile["first_name"] ?? "Beneficiary";
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, containerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Beneficiary",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _showProfileMenu,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    "Welcome, $displayName",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("😊", style: TextStyle(fontSize: 22)),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "AidBridge Secure Verification Enabled",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAidStatusCard() {
    final statusColorVal = hasToken ? successColor : accentColor;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Current Aid Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColorVal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tokenStatus.isEmpty
                      ? (hasToken ? "ACTIVE" : "INACTIVE")
                      : tokenStatus.toUpperCase(),
                  style: TextStyle(
                    color: statusColorVal,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Assigned Distribution Center",
                      style: TextStyle(color: textSecondaryColor, fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      centerName.isEmpty ? "Not Assigned" : centerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          Row(
            children: [
              Icon(
                hasToken
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: hasToken ? successColor : textSecondaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                hasToken ? "Active Token Ready" : "No Active Token",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveActions() {
    return BlocBuilder<TokenCubit, TokenState>(
      builder: (context, state) {
        final loading = state is TokenGenerating;

        // Determine behavior based on whether the user already has an active token
        final actionTitle = hasToken
            ? "View Active Aid Token"
            : "Generate Aid Token";
        final actionSubtitle = hasToken
            ? "Your token is active. Tap to view QR code"
            : "Request your active collection token/QR";

        final VoidCallback? onTapAction = loading
            ? null
            : () {
                if (hasToken &&
                    currentActiveToken != null &&
                    currentActiveToken!.isNotEmpty) {
                  _openQrCode(
                    currentActiveToken!,
                    expiryTime: currentExpiryTime,
                  );
                } else {
                  _generateToken();
                }
              };

        return Column(
          children: [
            _buildActionCardTile(
              icon: Icons.qr_code_2_rounded,
              title: actionTitle,
              subtitle: actionSubtitle,
              color: primaryColor,
              onTap: onTapAction,
            ),
            const SizedBox(height: 12),
            _buildActionCardTile(
              icon: Icons.history_edu_rounded,
              title: "Collection Records",
              subtitle: "Review your prior collection logs ($collectionCount)",
              color: secondaryColor,
              onTap: _openTokenStatus,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: textSecondaryColor, fontSize: 11),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: textSecondaryColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
