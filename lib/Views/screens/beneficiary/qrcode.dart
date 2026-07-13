import 'dart:async';
import 'dart:convert';

import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCode extends StatefulWidget {
  final String? token;
  final String? expiryTime;

  const QrCode({super.key, this.token, this.expiryTime});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  Timer? _timer;
  int timeLeft = 0;
  int totalDuration = 120; // Default reference window
  bool isExpired = false;
  bool showCode = false;
  late String manualToken;
  String? backendExpiryStr;
  String qrData = "";

  @override
  void initState() {
    super.initState();
    _resolveArguments();
    _prepareQr();
    _parseBackendExpiry();

    if (manualToken.isNotEmpty && !isExpired) {
      startTimer();
    }
  }

  // Robustly extract arguments or fallback to widget properties
  void _resolveArguments() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      manualToken = args["aid_token"]?.toString() ?? widget.token ?? "";
      backendExpiryStr = args["expiry_time"]?.toString() ?? widget.expiryTime;
    } else {
      manualToken = widget.token ?? args?.toString() ?? "";
      backendExpiryStr = widget.expiryTime;
    }

    // Debug log to trace what data is received on re-entry
    debugPrint(
      "QrCode initialized -> Token: $manualToken, ExpiryStr: $backendExpiryStr",
    );
  }

  void _prepareQr() {
    qrData = jsonEncode({"type": "AID_COLLECTION", "token": manualToken});
  }

  void _parseBackendExpiry() {
    if (backendExpiryStr != null && backendExpiryStr!.isNotEmpty) {
      try {
        final expiryDate = DateTime.parse(backendExpiryStr!);
        final now = DateTime.now();
        final difference = expiryDate.difference(now).inSeconds;

        if (difference > 0) {
          timeLeft = difference;
          // Keep a stable ceiling reference if totalDuration was smaller,
          // or set it to difference to reflect exact remaining block.
          totalDuration = difference > totalDuration
              ? difference
              : totalDuration;
          isExpired = false;
        } else {
          timeLeft = 0;
          isExpired = true;
        }
      } catch (e) {
        debugPrint("Error parsing expiry_time: $e");
        _applyFallbackExpiry();
      }
    } else {
      _applyFallbackExpiry();
    }
  }

  void _applyFallbackExpiry() {
    // Only use fallback if we genuinely have no expiry string provided
    timeLeft = 120;
    totalDuration = 120;
    isExpired = false;
  }

  void startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        setState(() {
          isExpired = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return "0:00";
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (days > 0) {
      return "$days d ${hours}h remaining";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m remaining";
    }
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (manualToken.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textColor,
        ),
        body: const Center(
          child: Text(
            "No active token found",
            style: TextStyle(
              color: textSecondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final progress = totalDuration > 0
        ? (timeLeft / totalDuration).clamp(0.0, 1.0)
        : 0.0;
    final activeColor = isExpired
        ? errorColor
        : timeLeft <= 30
        ? accentColor
        : successColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Digital Aid Token",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textColor,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: activeColor.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3.5,
                        color: activeColor,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExpired ? "Token Expired" : "Center Session Time",
                            style: TextStyle(
                              color: activeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isExpired
                                ? "Session window closed"
                                : _formatTime(timeLeft),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Aid Collection QR",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        QrImageView(
                          data: qrData,
                          size: 220,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: textColor,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: textColor,
                          ),
                        ),
                        if (isExpired)
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_off_outlined,
                                    color: errorColor,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Expired",
                                    style: TextStyle(
                                      color: errorColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Manual Token",
                            style: TextStyle(
                              color: textSecondaryColor,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            showCode ? manualToken : "••••••••••••",
                            style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: isExpired
                          ? null
                          : () {
                              setState(() {
                                showCode = !showCode;
                              });
                            },
                      icon: Icon(
                        showCode
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired
                        ? primaryColor
                        : successColor.withOpacity(0.12),
                    foregroundColor: isExpired ? Colors.white : successColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    isExpired ? "Generate New Token" : "Token Active",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isExpired ? Colors.white : successColor,
                    ),
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
