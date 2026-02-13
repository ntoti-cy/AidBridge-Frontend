import 'package:flutter/material.dart';

class myTextfield extends StatelessWidget {
final TextEditingController controller;
final IconData icon;
final String hint;
final bool password;
final ValueNotifier<bool>? passwordVisibilityNotifier;
final bool? obscureText;


const myTextfield({
super.key,
required this.controller,
required this.icon,
required this.hint,
this.password = false,
this.passwordVisibilityNotifier,
this.obscureText,
});


@override
Widget build(BuildContext context) {
return TextField(
controller: controller,
obscureText: obscureText ?? false,
decoration: InputDecoration(
hintText: hint,
prefixIcon: Icon(icon),
suffixIcon: password && passwordVisibilityNotifier != null
? ValueListenableBuilder<bool>(
valueListenable: passwordVisibilityNotifier!,
builder: (context, isVisible, _) {
return IconButton(
icon: Icon(
isVisible ? Icons.visibility : Icons.visibility_off,
),
onPressed: () {passwordVisibilityNotifier!.value =
!passwordVisibilityNotifier!.value;
},
);
},
)
: null,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(20),
),
),
);
}
}