import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Views/screens/beneficiary/qrcode.dart';
import 'package:aid_bridge/Views/screens/beneficiary/token_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BeneficiaryDashboard extends StatelessWidget {
  final String firstName;
  final String secondName;
  final bool isEligible;

  const BeneficiaryDashboard({
    super.key,
    required this.firstName,
    required this.secondName,
    this.isEligible = true,
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
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: TextStyle(color: textSecondaryColor, fontSize: 16),
                          ),
                          Text(
                            "$firstName 👋",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      _buildProfileIcon(),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                //Dynamic Color based on status
                _buildStatusBanner(),

                const SizedBox(height: 30),

            
                _buildHeroActionCard(),

                const SizedBox(height: 40),

                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Activity & Support",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: textColor,
                          letterSpacing: 0.5
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildModernListTile(
                        icon: Icons. receipt_long_rounded,
                        title: "Token History",
                        subtitle: "Track your aid collection journey",
                        color: Colors.blue,
                        onTap: () => Get.to(() => const TokenStatus()),
                      ),
                      const SizedBox(height: 12),
                      _buildModernListTile(
                        icon: Icons.help_outline_rounded,
                        title: "Help Center",
                        subtitle: "Need assistance? Contact us",
                        color: Colors.orange,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
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
        child: Icon(Icons.person_outline, color: primaryColor),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEligible ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isEligible ? Icons.check_circle_rounded : Icons.info_rounded,
            color: isEligible ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isEligible ? "You are eligible for aid today" : "No aid sessions available",
            style: TextStyle(
              color: isEligible ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(28), // Slightly smaller radius for a smaller card
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: CircleAvatar(
                radius: 50, // Reduced from 60
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24), // Reduced vertical padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded, 
                    color: Colors.white, 
                    size: 64, // Reduced from 80 to save space
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Ready to collect?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 20, // Slightly smaller font
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Show your unique QR code at the service\npoint to receive your supplies.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8), 
                      fontSize: 12, // Slightly smaller font
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: isEligible ? () => Get.to(() => const QrCode()) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "GENERATE TOKEN",
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernListTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required Color color,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: textSecondaryColor, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}