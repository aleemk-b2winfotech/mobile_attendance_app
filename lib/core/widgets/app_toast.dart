import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

final class AppToast {
  AppToast._();

  static void show(String message, {required bool isError}) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) return;

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          normalizedMessage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        icon: Icon(
          isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
          color: Colors.white,
        ),
        shouldIconPulse: false,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        duration: const Duration(seconds: 3),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void error(String message) => show(message, isError: true);

  static void success(String message) => show(message, isError: false);
}
