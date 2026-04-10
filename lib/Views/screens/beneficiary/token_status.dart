import 'package:aid_bridge/Configs/colors.dart';
import 'package:flutter/material.dart';

class TokenStatus extends StatelessWidget {
  const TokenStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // --- 1. SUBTLE GHOST HINTS (Top & Bottom only) ---
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.04,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Only 3 tiles at the top
                    ...List.generate(3, (index) => _buildGhostTile()),
                    const Spacer(),
                    // Only 2 tiles at the bottom
                    ...List.generate(2, (index) => _buildGhostTile()),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. THE SOFT FADE OVERLAY ---
          // This ensures the ghost tiles disappear as they approach the center
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    backgroundColor.withOpacity(0.0), // Show ghost at very top
                    backgroundColor,                 // Hide behind card
                    backgroundColor,                 // Hide behind card
                    backgroundColor.withOpacity(0.0), // Show ghost at very bottom
                  ],
                ),
              ),
            ),
          ),

          // --- 3. REFINED SMALLER CARD ---
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                // Reduced vertical padding to make card smaller
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Smaller Icon Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded, 
                        size: 40, // Reduced from 54
                        color: primaryColor
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "No History Found",
                      style: TextStyle(
                        fontSize: 20, // Reduced from 24
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your generated tokens and collection\nactivity will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondaryColor, 
                        fontSize: 13, // Reduced from 15
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGhostTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: textColor.withOpacity(0.5)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 8, width: 80, decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 6),
              Container(height: 5, width: 140, decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(4))),
            ],
          )
        ],
      ),
    );
  }
}