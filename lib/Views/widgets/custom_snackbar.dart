import 'dart:ui';

import 'package:get/get.dart';

void mySnackbar({required String title, required String message, required int type}) {
Get.snackbar(
title,
message,
snackPosition: SnackPosition.BOTTOM,
backgroundColor: type == 0 ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9),
colorText: const Color(0xFF000000),
);
}