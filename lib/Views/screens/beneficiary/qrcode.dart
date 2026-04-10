import 'package:aid_bridge/Configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  int maxTime = 120;
  int timeLeft = 120;
  Timer? _timer;
  bool isExpired = false;
  bool _showCode = false; // Controls visibility of the manual code

  final String manualToken = "AID-992-X8Z";
  final String qrData = '{"id":"22-2278", "token":"x8z-99a-secure", "exp":"120"}';

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        setState(() {
          isExpired = true;
          _timer?.cancel();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Helper to determine if we are in the "Warning Zone"
  bool get isWarning => timeLeft <= 30 && !isExpired;

  @override
  Widget build(BuildContext context) {
    double progress = timeLeft / maxTime;
    
    // Choose color based on time remaining
    Color activeColor = isExpired ? errorColor : (isWarning ? Colors.red : primaryColor);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Digital Aid Token", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- 1. THE QR VAULT AREA ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Opacity(
                      opacity: isExpired ? 0.2 : 1.0,
                      child: QrImageView(
                        data: qrData,
                        size: 200,
                        foregroundColor: textColor,
                      ),
                    ),
                  ),
                  
                  if (isExpired)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_off_rounded, size: 60, color: errorColor),
                        const SizedBox(height: 8),
                        const Text("EXPIRED", 
                          style: TextStyle(color: errorColor, fontWeight: FontWeight.bold))
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            // Time remaining text indicator
            Text(
              isExpired ? "Token has expired" : "Expires in $timeLeft seconds",
              style: TextStyle(
                color: activeColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 35),

            // --- 2. SECURE MANUAL CODE SECTION ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isWarning ? Colors.red.withOpacity(0.3) : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    "MANUAL COLLECTION CODE",
                    style: TextStyle(
                      fontSize: 11, 
                      letterSpacing: 1.2, 
                      fontWeight: FontWeight.bold,
                      color: textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Toggleable visibility text
                      Text(
                        isExpired 
                          ? "•••••••••••" 
                          : (_showCode ? manualToken : "•••••••••••"),
                        style: TextStyle(
                          fontSize: 24,
                          letterSpacing: _showCode ? 2 : 4,
                          fontWeight: FontWeight.w900,
                          color: isExpired ? Colors.grey : textColor,
                          fontFamily: 'Monospace',
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Visibility Toggle Button
                      IconButton(
                        onPressed: isExpired ? null : () {
                          setState(() => _showCode = !_showCode);
                        },
                        icon: Icon(
                          _showCode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: isExpired ? Colors.grey : primaryColor,
                        ),
                      )
                    ],
                  ),
                  const Text(
                    "Reveal only when asked by a distribution officer",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: textSecondaryColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildInfoTile(
              icon: isWarning ? Icons.warning_amber_rounded : Icons.security_rounded,
              title: isExpired ? "Token Invalid" : (isWarning ? "Expiring Soon!" : "Secure Token"),
              subtitle: isExpired 
                ? "Please generate a new token." 
                : "This code is unique to your account and session.",
              color: activeColor,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isExpired ? () {
                  setState(() {
                    timeLeft = maxTime;
                    isExpired = false;
                    _showCode = false; // Reset visibility on new token
                    startTimer();
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text(
                  isExpired ? "GENERATE NEW TOKEN" : "TOKEN ACTIVE",
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
              Text(subtitle, style: const TextStyle(color: textSecondaryColor, fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }
}