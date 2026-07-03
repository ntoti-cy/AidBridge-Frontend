import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();

  bool loading = true;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

    return "${first.isNotEmpty ? first[0] : ""}"
            "${second.isNotEmpty ? second[0] : ""}"
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
                    fontSize: 16,
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
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : user == null
          ? const Center(child: Text("Unable to load profile."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: primaryColor.withOpacity(.1),
                          child: Text(
                            _initials(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Full Name
                        Text(
                          "${user!["first_name"] ?? ""} ${user!["second_name"] ?? ""}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Email
                        Text(
                          user!["email"] ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: textSecondaryColor,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            (user!["role"] ?? "Beneficiary")
                                .toString()
                                .replaceAll("_", " ")
                                .toUpperCase(),
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Divider(color: Colors.grey.shade300, height: 1),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    color: successColor,
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(
                                    "Status",
                                    style: TextStyle(
                                      color: textSecondaryColor,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    user!["is_profile_complete"] == true
                                        ? "Complete"
                                        : "Pending",
                                    style: TextStyle(
                                      color:
                                          user!["is_profile_complete"] == true
                                          ? successColor
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 55,
                              color: Colors.grey.shade300,
                            ),

                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.badge_outlined,
                                    color: primaryColor,
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(
                                    "National ID",
                                    style: TextStyle(
                                      color: textSecondaryColor,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    user!["national_id"]?.toString() ?? "-",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
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
                            Icon(Icons.person_outline, color: primaryColor),

                            SizedBox(width: 10),

                            Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        _buildProfileRow(
                          icon: Icons.badge_outlined,
                          title: "First Name",
                          value: user!["first_name"]?.toString() ?? "-",
                        ),

                        const Divider(),

                        _buildProfileRow(
                          icon: Icons.badge_outlined,
                          title: "Second Name",
                          value: user!["second_name"]?.toString() ?? "-",
                        ),

                        const Divider(),

                        _buildProfileRow(
                          icon: Icons.email_outlined,
                          title: "Email",
                          value: user!["email"]?.toString() ?? "-",
                        ),

                        const Divider(),

                        _buildProfileRow(
                          icon: Icons.phone_outlined,
                          title: "Phone",
                          value: user!["contact"]?.toString() ?? "-",
                        ),

                        const Divider(),

                        _buildProfileRow(
                          icon: Icons.credit_card,
                          title: "National ID",
                          value: user!["national_id"]?.toString() ?? "-",
                        ),

                        if (user!["center_name"] != null) ...[
                          const Divider(),

                          _buildProfileRow(
                            icon: Icons.location_on_outlined,
                            title: "Distribution Centre",
                            value: user!["center_name"].toString(),
                          ),
                        ],

                        if (user!["income_level"] != null) ...[
                          const Divider(),

                          _buildProfileRow(
                            icon: Icons.payments_outlined,
                            title: "Monthly Income",
                            value: "KES ${user!["income_level"]}",
                          ),
                        ],

                        if (user!["total_members"] != null) ...[
                          const Divider(),

                          _buildProfileRow(
                            icon: Icons.groups_outlined,
                            title: "Household Members",
                            value: user!["total_members"].toString(),
                          ),
                        ],

                        if (user!["dependents_count"] != null) ...[
                          const Divider(),

                          _buildProfileRow(
                            icon: Icons.child_care_outlined,
                            title: "Dependents",
                            value: user!["dependents_count"].toString(),
                          ),
                        ],

                        if (user!["disability_present"] != null) ...[
                          const Divider(),

                          _buildProfileRow(
                            icon: Icons.accessible_forward,
                            title: "Disability Present",
                            value: user!["disability_present"] == true
                                ? "Yes"
                                : "No",
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
