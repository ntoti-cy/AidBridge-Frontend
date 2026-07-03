import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Settings extends StatefulWidget {
   Settings({super.key});

  

  @override
  State<Settings> createState() =>
      _SettingsScreenState();
}

final AuthService _authService = AuthService();

class _SettingsScreenState
    extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        centerTitle: true,

        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // Profile Header

              const SizedBox(height: 20),

              // =========================
// ACCOUNT
// =========================

const Padding(
  padding: EdgeInsets.only(left: 6),
  child: Text(
    "Account",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
  ),
),

const SizedBox(height: 18),

// =========================
// VIEW PROFILE
// =========================

Container(
  decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.grey.shade200,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 8,
    ),
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.person_outline,
        color: primaryColor,
      ),
    ),
    title: const Text(
      "View Profile",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: const Text(
      "View your personal information",
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 18,
    ),
    onTap: () {
      // TODO:
      // Get.to(() => const ProfileScreen());
    },
  ),
),

const SizedBox(height: 18),

// =========================
// CHANGE PASSWORD
// =========================

Container(
  decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.grey.shade200,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 8,
    ),
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.lock_outline,
        color: Colors.orange,
      ),
    ),
    title: const Text(
      "Change Password",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: const Text(
      "Update your account password",
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 18,
    ),
    onTap: () {
      // TODO:
      // Get.to(() => const ChangePasswordScreen());
    },
  ),
),

const SizedBox(height: 30),

// =========================
// LOGOUT
// =========================

Container(
  decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.red.shade100,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 8,
    ),
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.logout_rounded,
        color: Colors.red,
      ),
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
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 18,
      color: Colors.red,
    ),
      onTap: () async {
  final logout = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
            ),
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
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (logout == true) {
    await _authService.logout();

    Get.offAllNamed(AppRoutes.login);
  }
    },
  ),
),

const SizedBox(height: 30),

Center(
  child: Text(
    "AidBridge v1.0.0",
    style: TextStyle(
      color: Colors.grey.shade600,
      fontSize: 13,
    ),
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