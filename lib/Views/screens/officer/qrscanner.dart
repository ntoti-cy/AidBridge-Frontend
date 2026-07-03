import 'dart:convert';

import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/help/db_helper.dart';
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
  // Controllers
  //--------------------------------------------------

  final MobileScannerController scanner = MobileScannerController();

  final DBHelper db = DBHelper();

  //--------------------------------------------------
  // State
  //--------------------------------------------------

  bool processing = false;
  bool torch = false;
  bool offline = false;

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

      final token = payload["token"];


      context.read<OfficerCubit>().verifyToken(token);
    } catch (_) {
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
      builder: (_) {
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
                    Navigator.pop(context);

                    setState(() {
                      processing = true;
                      status = "Verifying...";
                      statusColor = Colors.orange;
                    });

                    context.read<OfficerCubit>().verifyToken(
                      controller.text.trim(),
                    );
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
  // Snackbar
  //--------------------------------------------------

  void _message(String text, Color color) {
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
  // Success Bottom Sheet
  //--------------------------------------------------

  void _successSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
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

              _infoTile("Name", data["beneficiary_name"] ?? "-"),

              _infoTile("National ID", data["national_id"] ?? "-"),

              _infoTile("Centre", data["distribution_center"] ?? "-"),

              _infoTile("Household", "${data["household_members"] ?? "-"}"),

              const SizedBox(height: 22),

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

                    context.read<OfficerCubit>().distributeAid(
                      data["aid_token"],
                    );
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
  // Failure Bottom Sheet
  //--------------------------------------------------

  void _failureSheet(String title, String message) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  //------------------------------------------------
                  // Status Card
                  //------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: statusColor.withOpacity(.12),
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: statusColor,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Aid Verification",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),

                              const SizedBox(height: 4),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  status,
                                  key: ValueKey(status),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  //------------------------------------------------
                  // Camera Scanner
                  //------------------------------------------------
                  Container(
                    height: 420,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,

                    child: Stack(
                      children: [
                        MobileScanner(controller: scanner, onDetect: _onDetect),

                        Container(color: Colors.black.withOpacity(.35)),

                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: processing
                                    ? Colors.orange
                                    : primaryColor,
                                width: 4,
                              ),
                            ),
                          ),
                        ),

                        if (processing)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),

                                  SizedBox(height: 16),

                                  Text(
                                    "Verifying Token...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  "Align the QR code inside the frame",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "Scanning happens automatically",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  //------------------------------------------------
                  // Controls
                  //------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(torch ? Icons.flash_on : Icons.flash_off),
                          label: Text(torch ? "Torch On" : "Torch Off"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: primaryColor),
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
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.keyboard),
                          label: const Text("Manual Entry"),
                          onPressed: _manualEntry,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  //------------------------------------------------
                  // Offline Notice
                  //------------------------------------------------
                  if (offline)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wifi_off, color: Colors.orange),

                          SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              "Offline verification uses your downloaded beneficiary database.",
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
