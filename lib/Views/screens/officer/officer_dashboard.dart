import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Views/screens/officer/qrscanner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfficerDashboard extends StatelessWidget {
  final String firstName;
  final String secondName;
  final String aidCenter;
  final String token; // The JWT token to pass to the scanner

  const OfficerDashboard({
    super.key,
    required this.firstName,
    required this.secondName,
    required this.aidCenter,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: primaryColor.withOpacity(0.05),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Officer Portal,",
                            style: TextStyle(color: textSecondaryColor, fontSize: 16),
                          ),
                          Text(
                            "$firstName $secondName",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      _buildProfileIcon(),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Center Assignment Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Assigned Distribution Center", 
                                style: TextStyle(fontSize: 12, color: textSecondaryColor)),
                              Text(aidCenter, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Hero Scanner Button
                  InkWell(
                    onTap: () => Get.to(() => QRScanner(token: token)),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 80, color: Colors.white),
                          SizedBox(height: 20),
                          Text(
                            "SCAN AID TOKEN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tap to open camera viewfinder",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.beneficiaryList, arguments: {'token': token}),
                      icon: const Icon(Icons.cloud_download_rounded),
                      label: const Text("Offline Sync Menu"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
      ),
      child: const CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: Icon(Icons.admin_panel_settings_rounded, color: primaryColor),
      ),
    );
  }
}