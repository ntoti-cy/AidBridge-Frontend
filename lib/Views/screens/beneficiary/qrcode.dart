import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Ensure this package is in pubspec.yaml
import 'dart:async'; // Required for the Timer

class Qrcode extends StatefulWidget {
  const Qrcode({super.key});

  @override
  _QrDisplayScreenState createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<Qrcode> {
  // CONFIGURATION
  int timeLeft = 120; // 2 Minutes in seconds
  Timer? _timer;
  bool isExpired = false;
  // ignore: unused_field
  double _originalBrightness = 0.5;

  // This is the "Secure Payload" - In reality, this comes from your database
  // It contains the ID + Timestamp + Secret Hash
  final String qrData = '{"id":"22-2278", "token":"x8z-99a-secure", "exp":"120"}';

  @override
  void initState() {
    super.initState();
    startTimer();
    setHighBrightness();
  }

  void setHighBrightness() {
    // In a real app, use the 'screen_brightness' package here.
    // For now, we simulate it by just printing to console.
    print("Setting Screen Brightness to 100%");
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        // Time is up!
        setState(() {
          isExpired = true;
          _timer?.cancel();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Always stop the timer when leaving the screen
    super.dispose();
  }

  // Helper to format 120 seconds into "02:00"
  String get timerText {
    int minutes = timeLeft ~/ 60;
    int seconds = timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Secure Token"),
        backgroundColor: isExpired ? Colors.grey : Colors.blue[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            // --- UI ELEMENT: STATUS LABEL (Page 4 Logic) ---
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: isExpired ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isExpired ? "TOKEN EXPIRED" : "TOKEN ACTIVE",
                style: TextStyle(
                  color: isExpired ? Colors.red : Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 30),

            // --- UI ELEMENT: QR CODE (Page 3 Logic) ---
            Stack(
              alignment: Alignment.center,
              children: [
                // The QR Code
                Opacity(
                  opacity: isExpired ? 0.1 : 1.0, // Fade out if expired
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 280.0,
                  ),
                ),
                // Overlay "Expired" icon if time is up
                if (isExpired)
                  Icon(Icons.lock_clock, size: 80, color: Colors.red),
              ],
            ),
            
            SizedBox(height: 30),

            // --- UI ELEMENT: COUNTDOWN TIMER ---
            Text(
              isExpired ? "00:00" : timerText,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'Monospace', // Looks like a digital clock
                color: isExpired ? Colors.red : Colors.black,
              ),
            ),
            Text(
              "Expires in",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 40),

            // --- UI ELEMENT: REFRESH BUTTON ---
            // Only clickable if expired
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isExpired 
                  ? () {
                      // Reset Logic
                      setState(() {
                        timeLeft = 120;
                        isExpired = false;
                        startTimer();
                      });
                    } 
                  : null, // Disabled if still active
                icon: Icon(Icons.refresh),
                label: Text("GENERATE NEW TOKEN"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue[800],
                ),
              ),
            ),
            
            SizedBox(height: 10),
            Text(
              "Do not screenshot. This code is time-sensitive.",
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}