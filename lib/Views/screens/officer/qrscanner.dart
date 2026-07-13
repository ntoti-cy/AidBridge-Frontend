import 'dart:convert';

import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/officer/officer_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_state.dart';
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
  //--------------------------------------------------
  // Scanner Controller
  //--------------------------------------------------

  final MobileScannerController scanner = MobileScannerController();

  //--------------------------------------------------
  // State
  //--------------------------------------------------

  bool processing = false;
  bool torch = false;
  String status = "Ready to Scan";
  Color statusColor = successColor;

  //--------------------------------------------------
  // Dispose
  //--------------------------------------------------

  @override
  void dispose() {
    scanner.dispose();
    super.dispose();
  }

  //--------------------------------------------------
  // QR Detection
  //--------------------------------------------------

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

      context.read<OfficerCubit>().verifyToken(token);
    } catch (e) {
      _failureSheet(
        "Invalid QR Code",
        "The scanned QR code is not recognised.",
      );
    }
  }

  //--------------------------------------------------
  // Manual Entry
  //--------------------------------------------------

  void _manualEntry() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            children: [
              const Text(
                "Manual Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Beneficiary Token",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
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
                  ),
                  onPressed: () {
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

                    context.read<OfficerCubit>().verifyToken(token);
                  },
                  child: const Text("Verify Token"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //--------------------------------------------------
  // Restart Scanner
  //--------------------------------------------------

  Future<void> _restartScanner() async {
    if (!mounted) return;

    setState(() {
      processing = false;
      status = "Ready to Scan";
      statusColor = successColor;
    });

    await scanner.start();
  }

  //--------------------------------------------------
  // Message
  //--------------------------------------------------

  void _message(String text, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: color, content: Text(text)));
  }

  //--------------------------------------------------
  // Information Tile
  //--------------------------------------------------

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(color: textSecondaryColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // Success Sheet
  //--------------------------------------------------

  void _successSheet(Map<String, dynamic> data) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: successColor.withOpacity(.12),
                child: const Icon(
                  Icons.check_circle,
                  color: successColor,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Beneficiary Verified",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "The beneficiary is eligible to receive aid.",
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondaryColor),
              ),
              const SizedBox(height: 24),
              _infoTile("Name", data["beneficiary_name"]?.toString() ?? "-"),
              _infoTile("National ID", data["national_id"]?.toString() ?? "-"),
              _infoTile(
                "Centre",
                data["distribution_center"]?.toString() ?? "-",
              ),
              _infoTile(
                "Household",
                data["household_members"]?.toString() ?? "-",
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text("Distribute Aid"),
                  onPressed: () {
                    Navigator.pop(context);
                    final token =
                        data["aid_token"]?.toString() ??
                        data["token"]?.toString();

                    if (token != null && token.isNotEmpty) {
                      context.read<OfficerCubit>().distributeAid(token);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _restartScanner();
                },
                child: const Text("Scan Another"),
              ),
            ],
          ),
        );
      },
    );
  }

  //--------------------------------------------------
  // Failure Sheet
  //--------------------------------------------------

  void _failureSheet(String title, String message) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: errorColor.withOpacity(.12),
                child: const Icon(Icons.cancel, color: errorColor, size: 46),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textSecondaryColor),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _restartScanner();
                  },
                  child: const Text("Scan Again"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //--------------------------------------------------
  // Build
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfficerCubit, OfficerState>(
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
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            centerTitle: true,
            title: const Text(
              "Verify Beneficiary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: Get.back,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Aid Verification",
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 20,
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
                        height: 280,
                        width: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.5),
                            width: 2,
                          ),
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
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: textColor,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await scanner.toggleTorch();
                          setState(() {
                            torch = !torch;
                          });
                        },
                        icon: Icon(
                          torch ? Icons.flash_on : Icons.flash_off,
                          color: torch ? primaryColor : textColor,
                        ),
                        label: Text(torch ? "Torch On" : "Torch Off"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _manualEntry,
                        icon: const Icon(Icons.keyboard),
                        label: const Text("Manual Entry"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Offline Database Indicator
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_done, size: 16, color: successColor),
                      SizedBox(width: 8),
                      Text(
                        "Offline database available",
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
