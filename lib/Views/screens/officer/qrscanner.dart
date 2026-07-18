import 'dart:convert';
import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/connectivity/connectivity_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_state.dart';
import 'package:aid_bridge/Local/offline_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final MobileScannerController scanner = MobileScannerController();

  bool get isOffline => context.read<ConnectivityCubit>().state.isOffline;
  bool processing = false;
  bool torch = false;
  String status = "Ready to Scan";
  Color statusColor = successColor;

  @override
  void dispose() {
    scanner.dispose();
    super.dispose();
  }

  // QR Detection
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (processing) return;

    if (capture.barcodes.isEmpty) return;

    final raw = capture.barcodes.first.rawValue;

    if (raw == null) return;

    setState(() {
      processing = true;
      status = "Verifying...";
      statusColor = Colors.orange;
    });

    await scanner.stop();

    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      // Adjusted to support both "token" and Flask backend "aid_token" keys safely
      final token =
          payload["token"]?.toString() ?? payload["aid_token"]?.toString();

      if (token == null || token.isEmpty) {
        _failureSheet("Invalid QR Code", "Token was not found.");
        return;
      }

      if (isOffline) {
        context.read<OfflineCubit>().verifyBeneficiary(token);
      } else {
        context.read<OfficerCubit>().verifyToken(token);
      }
    } catch (e) {
      _failureSheet(
        "Invalid QR Code",
        "The scanned QR code is not recognised.",
      );
    }
  }

  // Manual Entry
  void _manualEntry() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manual Verification",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Enter beneficiary aid token code manually.",
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Beneficiary Token",
                  prefixIcon: const Icon(
                    Icons.qr_code_rounded,
                    color: primaryColor,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final token = controller.text.trim();
                    Navigator.pop(context);

                    if (token.isEmpty) {
                      _failureSheet(
                        "Missing Token",
                        "Enter a valid beneficiary token.",
                      );
                      return;
                    }

                    setState(() {
                      processing = true;
                      status = "Verifying...";
                      statusColor = Colors.orange;
                    });

                    if (isOffline) {
                      context.read<OfflineCubit>().verifyBeneficiary(token);
                    } else {
                      context.read<OfficerCubit>().verifyToken(token);
                    }
                  },
                  child: const Text(
                    "Verify Token",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Restart Scanner
  Future<void> _restartScanner() async {
    if (!mounted) return;

    setState(() {
      processing = false;
      status = "Ready to Scan";
      statusColor = successColor;
    });

    await scanner.start();
  }

  // Message
  void _message(String text, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Information Tile
  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(color: textSecondaryColor, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Success Sheet
  void _successSheet(Map<String, dynamic> data) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: successColor.withOpacity(0.1),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: successColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Beneficiary Verified",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "The beneficiary is eligible to receive aid.",
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondaryColor, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _infoTile(
                "Name",
                data["beneficiary_name"]?.toString() ??
                    data["name"]?.toString() ??
                    "-",
              ),
              _infoTile("National ID", data["national_id"]?.toString() ?? "-"),
              _infoTile(
                "Centre",
                data["distribution_center"]?.toString() ?? "-",
              ),
              _infoTile(
                "Household",
                data["household_members"]?.toString() ??
                    data["total_members"]?.toString() ??
                    "-",
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.volunteer_activism_rounded, size: 20),
                  label: const Text(
                    "Distribute Aid",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final token =
                        data["aid_token"]?.toString() ??
                        data["token"]?.toString();

                    if (token != null && token.isNotEmpty) {
                      if (isOffline) {
                        context.read<OfflineCubit>().collectAid(
                          aidToken: token,
                          beneficiaryId: data["id"],
                          officerId: data["officer_id"],
                          sessionId: data["distribution_session_id"],
                          center: data["distribution_center"],
                        );
                      } else {
                        context.read<OfficerCubit>().distributeAid(token);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _restartScanner();
                },
                child: const Text(
                  "Scan Another",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Failure Sheet
  void _failureSheet(String title, String message) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: errorColor.withOpacity(0.1),
                child: const Icon(
                  Icons.cancel_rounded,
                  color: errorColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textSecondaryColor, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _restartScanner();
                  },
                  child: const Text(
                    "Scan Again",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<ConnectivityCubit>().state.isOffline;
    return BlocListener<OfflineCubit, OfflineState>(
      listener: (context, state) async {
        if (state is OfflineLoading) {
          setState(() {
            processing = true;
            status = "Verifying...";
            statusColor = Colors.orange;
          });
        }

        if (state is BeneficiaryVerified) {
          setState(() {
            processing = false;
            status = "Verified";
            statusColor = successColor;
          });

          _successSheet({
            "aid_token": state.beneficiary.aidToken,
            "name": state.beneficiary.name,
            "national_id": state.beneficiary.nationalId,
            "distribution_center": state.beneficiary.distributionCenter,
            "total_members": state.beneficiary.totalMembers,
          });
        }

        if (state is OfflineFailure) {
          setState(() {
            processing = false;
            status = "Verification Failed";
            statusColor = errorColor;
          });

          _failureSheet("Verification Failed", state.message);
        }

        if (state is AidCollectedOffline) {
          _message(state.message, successColor);

          await _restartScanner();
        }
      },
      child: BlocConsumer<OfficerCubit, OfficerState>(
        listener: (context, state) async {
          if (!mounted) return;
          if (state is OfficerLoading) {
            setState(() {
              processing = true;
              status = "Verifying...";
              statusColor = Colors.orange;
            });
          }

          if (state is TokenVerified) {
            setState(() {
              processing = false;
              status = "Verified";
              statusColor = successColor;
            });

            _successSheet(state.beneficiary);
          }

          if (state is AidDistributed) {
            _message("Aid distributed successfully.", successColor);
            await _restartScanner();
          }

          if (state is OfficerFailure) {
            setState(() {
              processing = false;
              status = "Verification Failed";
              statusColor = errorColor;
            });

            _failureSheet("Verification Failed", state.message);
          }

          if (state is OfficerSyncSuccess) {
            _message("${state.synced} records synchronized.", successColor);
          }

          if (state is BeneficiariesDownloaded) {
            _message("${state.count} beneficiaries downloaded.", successColor);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: textColor,
              centerTitle: true,
              title: const Text(
                "Verify Beneficiary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: Get.back,
              ),
            ),
            body: AppBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
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
                        child: Column(
                          children: [
                            const Text(
                              "Aid Verification Status",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // QR Camera Scanner Frame
                      Expanded(
                        child: Center(
                          child: Container(
                            height: 260,
                            width: 260,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.05),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: MobileScanner(
                                controller: scanner,
                                onDetect: _onDetect,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Controls Row (Torch & Manual Entry)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cardColor,
                                foregroundColor: textColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: Colors.grey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                await scanner.toggleTorch();
                                setState(() {
                                  torch = !torch;
                                });
                              },
                              icon: Icon(
                                torch
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: torch ? primaryColor : textColor,
                                size: 18,
                              ),
                              label: Text(
                                torch ? "Torch On" : "Torch Off",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _manualEntry,
                              icon: const Icon(
                                Icons.keyboard_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                "Manual Entry",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Offline Database Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOffline
                                ? Icons.cloud_off_rounded
                                : Icons.cloud_done_rounded,
                            size: 16,
                            color: isOffline ? errorColor : successColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isOffline
                                ? "Offline Verification Mode"
                                : "Online Verification Mode",
                            style: TextStyle(
                              color: isOffline
                                  ? errorColor
                                  : textSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
