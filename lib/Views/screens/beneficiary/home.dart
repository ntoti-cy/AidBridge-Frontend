import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userId;
  final int familySize;
  final String location;
  final bool isEligible;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.familySize,
    required this.location,
    required this.isEligible,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("AidBridge"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.offAllNamed(AppRoutes.login),
          )
        ],
      ),

      body: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // --- WELCOME ---
              Text(
                "Welcome,",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // --- PROFILE INFO ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Household Size: $familySize"),
                      Text("Location: $location"),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 25),

              // --- STATUS ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isEligible ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEligible ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEligible ? Icons.check_circle : Icons.cancel,
                      color: isEligible ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEligible ? "ELIGIBLE FOR AID" : "AID ALREADY COLLECTED",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isEligible ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- QR BUTTON ---
              ElevatedButton.icon(
                onPressed: isEligible
                    ? () => Get.toNamed(AppRoutes.qrcode)
                    : null,
                icon: const Icon(Icons.qr_code_2),
                label: const Text("SHOW MY QR CODE"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
