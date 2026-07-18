import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/connectivity/connectivity_cubit.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfficerProfile extends StatefulWidget {
  const OfficerProfile({super.key});

  @override
  State<OfficerProfile> createState() => _OfficerProfileState();
}

class _OfficerProfileState extends State<OfficerProfile> {
  final AuthService _authService = AuthService();
  bool loading = true;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();

    final offline = context.read<ConnectivityCubit>().state.isOffline;

    if (!offline) {
      _loadProfile();
    } else {
      loading = false;
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (!mounted) return;
      setState(() {
        user = profile;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  String _initials() {
    if (user == null) return "";
    final first = user!["first_name"]?.toString() ?? "";
    final second = user!["second_name"]?.toString() ?? "";
    return "${first.isNotEmpty ? first[0] : ""}${second.isNotEmpty ? second[0] : ""}"
        .toUpperCase();
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Officer Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        centerTitle: true,
      ),
      body: AppBackground(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : user == null
            ? const Center(
                child: Text(
                  "Profile is only available while online.",
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Header card with avatar & role
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: primaryColor.withOpacity(.1),
                            child: Text(
                              _initials(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "${user!["first_name"] ?? ""} ${user!["second_name"] ?? ""}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user!["email"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              (user!["role"] ?? "Field Officer")
                                  .toString()
                                  .replaceAll("_", " ")
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Officer Information Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                color: primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Officer Information",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildProfileRow(
                            icon: Icons.badge_outlined,
                            title: "First Name",
                            value: user!["first_name"]?.toString() ?? "-",
                          ),
                          const Divider(height: 16),
                          _buildProfileRow(
                            icon: Icons.badge_outlined,
                            title: "Second Name",
                            value: user!["second_name"]?.toString() ?? "-",
                          ),
                          const Divider(height: 16),
                          _buildProfileRow(
                            icon: Icons.phone_outlined,
                            title: "Phone Number",
                            value: user!["contact"]?.toString() ?? "-",
                          ),
                          const Divider(height: 16),
                          _buildProfileRow(
                            icon: Icons.email_outlined,
                            title: "Email",
                            value: user!["email"]?.toString() ?? "-",
                          ),
                          const Divider(height: 16),
                          _buildProfileRow(
                            icon: Icons.credit_card_rounded,
                            title: "National ID",
                            value: user!["national_id"]?.toString() ?? "-",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Employment Information Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.work_outline_rounded,
                                color: secondaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Employment Information",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildProfileRow(
                            icon: Icons.admin_panel_settings_outlined,
                            title: "Role",
                            value: (user!["role"] ?? "Field Officer")
                                .toString()
                                .replaceAll("_", " ")
                                .toUpperCase(),
                          ),
                          const Divider(height: 16),
                          _buildProfileRow(
                            icon: Icons.location_on_outlined,
                            title: "Assigned Distribution Centre",
                            value:
                                user!["assigned_center_name"]?.toString() ??
                                "Not Assigned",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
