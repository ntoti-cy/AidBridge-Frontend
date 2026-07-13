import 'package:flutter/material.dart';
import 'colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showDecorations;

  const AppBackground({
    super.key,
    required this.child,
    this.showDecorations = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEAF4FF),
                Colors.white,
                Color(0xFFDCEBFF),
                Color(0xFFF7FBFF),
              ],
            ),
          ),
        ),

        /// Top Right Circle (Conditional)
        if (showDecorations)
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(.08),
              ),
            ),
          ),

        /// Bottom Left Circle (Conditional)
        if (showDecorations)
          Positioned(
            bottom: -80,
            left: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlue.withOpacity(.08),
              ),
            ),
          ),

        /// Screen Content
        SafeArea(child: child),
      ],
    );
  }
}
