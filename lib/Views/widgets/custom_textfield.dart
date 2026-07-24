import 'package:aid_bridge/Configs/colors.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;

  final bool password;
  final ValueNotifier<bool>? passwordVisibilityNotifier;
  final bool? obscureText;
  final ValueChanged<String>? onChanged;

  final String? errorText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    this.password = false,
    this.passwordVisibilityNotifier,
    this.obscureText,
    this.errorText,
    this.onChanged,
  });

  InputDecoration buildDecoration({
    required String label,
    required IconData icon,
    String? error,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),

      errorText: error,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2.5),
      ),

      suffixIcon: password && passwordVisibilityNotifier != null
          ? ValueListenableBuilder<bool>(
              valueListenable: passwordVisibilityNotifier!,
              builder: (context, isVisible, _) {
                return IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    passwordVisibilityNotifier!.value =
                        !passwordVisibilityNotifier!.value;
                  },
                );
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Password field
    if (password && passwordVisibilityNotifier != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: passwordVisibilityNotifier!,
        builder: (context, isVisible, child) {
          return TextField(
            controller: controller,
            obscureText: !isVisible,
            onChanged: onChanged,
            decoration: buildDecoration(
              label: hint,
              icon: icon,
              error: errorText,
            ),
          );
        },
      );
    }

    // Normal field
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: buildDecoration(label: hint, icon: icon, error: errorText),
    );
  }
}
