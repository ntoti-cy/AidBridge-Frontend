import 'dart:convert';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Dio/dio_client.dart';
import 'package:aid_bridge/Controllers/help/db_helper.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner extends StatefulWidget {
  final String token; // JWT for Dio

  const QRScanner({super.key, required this.token});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner > {
  final MobileScannerController scannerController = MobileScannerController();
  final DBHelper db = DBHelper();
  
  bool isProcessing = false;
  bool isTorchOn = false;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  //  Detect & Parse
  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    setState(() => isProcessing = true);
    await scannerController.stop(); // Pause immediately to prevent spamming the API

    try {
      final Map<String, dynamic> payload = jsonDecode(barcodes.first.rawValue!);
      
      // Extract the 'token' field based on the Beneficiary QR format
      final String? extractedToken = payload['token']; 
      
      if (extractedToken == null) throw const FormatException("Invalid Token Format");
      
      await _verifyToken(extractedToken);

    } catch (e) {
      _showResultDialog(false, "Invalid QR Code", "This QR code does not belong to the AidBridge system.");
    }
  }

  //  Network Check & Verification
  Future<void> _verifyToken(String aidToken) async {
    try {
      // Check network state
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
      final bool isOnline = connectivityResult.isNotEmpty && !connectivityResult.contains(ConnectivityResult.none);

      if (isOnline) {
        // ONLINE MODE
        final response = await DioClient.dio.post(
          '/api/officer/verify-token',
          data: {"aid_token": aidToken},
          options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
        );

        if (response.statusCode == 200) {
          _showResultDialog(
            true, 
            "Verification Success", 
            "Beneficiary ID: ${response.data['beneficiary_id']}\nCenter: ${response.data['distribution_center']}"
          );
        }
      } else {
        // OFFLINE MODE fallback
        String status = await db.getTokenStatus(aidToken);
        if (status == 'active') {
          // TODO: Add db.markTokenAsUsed(aidToken) to your DBHelper
          _showResultDialog(true, "Offline Success", "Token verified locally. Please sync later.");
        } else if (status.isEmpty) {
          _showResultDialog(false, "Offline Error", "Token not found in local database.");
        } else {
          _showResultDialog(false, "Token Invalid", "Token status is: $status");
        }
      }
    } on DioException catch (e) {
      String errorMsg = e.response?.data['error'] ?? "An unexpected server error occurred.";
      _showResultDialog(false, "Verification Failed", errorMsg);
    } catch (e) {
      _showResultDialog(false, "Error", "Something went wrong.");
    }
  }

  // Handle Result & Resume
  void _showResultDialog(bool isSuccess, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded, 
                color: isSuccess ? successColor : errorColor, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              setState(() => isProcessing = false);
              scannerController.start(); // Resume scanner
            },
            child: const Text("Next Beneficiary"),
          )
        ],
      )
    );
  }

  // MANUAL ENTRY FALLBACK
  void _showManualEntrySheet() {
    final TextEditingController manualController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Manual Entry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Enter the secure code displayed on the Beneficiary's screen.", style: TextStyle(color: textSecondaryColor)),
            const SizedBox(height: 20),
            TextField(
              controller: manualController,
              decoration: InputDecoration(
                labelText: "Token Code (e.g. AID-992-X8Z)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async{
                  Navigator.pop(context);
                  setState(() => isProcessing = true);
                  await scannerController.stop();
                  // For manual entry, we pass the raw string exactly as typed
                  _verifyToken(manualController.text.trim());
                },
                child: const Text("Verify Manual Token"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: _onDetect,
          ),
          
          // Viewfinder Overlay
          Column(
            children: [
              Expanded(child: Container(color: Colors.black54)),
              Row(
                children: [
                  Expanded(child: Container(color: Colors.black54)),
                  Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: isProcessing ? Colors.orange : primaryColor, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isProcessing 
                        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                        : null,
                  ),
                  Expanded(child: Container(color: Colors.black54)),
                ],
              ),
              Expanded(child: Container(color: Colors.black54)),
            ],
          ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  IconButton(
                    icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                    onPressed: () {
                      scannerController.toggleTorch();
                      setState(() => isTorchOn = !isTorchOn);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showManualEntrySheet,
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        icon: const Icon(Icons.keyboard_alt_outlined),
        label: const Text("Manual Entry", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}