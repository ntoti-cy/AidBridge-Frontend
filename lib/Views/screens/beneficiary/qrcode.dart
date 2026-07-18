import 'dart:async';
import 'dart:convert';

import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/connectivity/connectivity_cubit.dart';
import 'package:aid_bridge/Local/offline_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // 1 & 2: Resolved arguments without executing setState during initState
    _resolveArguments();
    _prepareQr();
    _parseBackendExpiry();

    if (context.read<ConnectivityCubit>().state.isOffline) {
      context.read<OfflineCubit>().loadBeneficiaryDashboard();
    }

    if (manualToken.isNotEmpty && !isExpired) {
      startTimer();
    }
  }

  // 4: Helper for runtime updates with optimization to avoid redundant rebuilds
  void _loadToken({required String token, required String? expiry}) {
    if (!mounted) return;
    if (manualToken == token && backendExpiryStr == expiry) {
      return;
    }

    setState(() {
      manualToken = token;
      backendExpiryStr = expiry;
      isExpired = false;
      timeLeft = 0;
      totalDuration = 0;
    });

    _prepareQr();
    _parseBackendExpiry();

    _timer?.cancel();
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
        final expiryDate = DateTime.parse(backendExpiryStr!).toLocal();
        final now = DateTime.now();
        final difference = expiryDate.difference(now).inSeconds;

        if (difference > 0) {
          timeLeft = difference;
          totalDuration = difference;
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
    final isOffline = context.watch<ConnectivityCubit>().state.isOffline;

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

    return BlocListener<OfflineCubit, OfflineState>(
      // 3: Safe listener guarding against missing token fields
      listener: (context, state) {
        if (state is OfflineBeneficiaryLoaded) {
          if (state.tokens.isNotEmpty) {
            final tokenData = state.tokens.first;
            _loadToken(
              token: tokenData["aid_token"] ?? "",
              expiry: tokenData["expiry_time"],
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Digital Aid Token",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (isOffline) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "OFFLINE",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
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
                // 7: Reassuring offline info banner if disconnected
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
                            // 5: Accurate description card labels instead of action phrases
                            Text(
                              isExpired
                                  ? "Expired"
                                  : isOffline
                                  ? "Offline Token"
                                  : "Active Token",
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
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Aid Collection QR",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                              "Manual Verification Token",
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
                      if (isExpired && isOffline) {
                        Get.snackbar(
                          "Offline",
                          "Connect to the internet to generate a new token.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      Get.back();
                    },
                    child: Text(
                      isExpired
                          ? "Generate New Token"
                          : isOffline
                          ? "Offline Token"
                          : "Token Active",
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
      ),
    );
  }
}
