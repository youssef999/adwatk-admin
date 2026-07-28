import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message) {
    Get.snackbar(
      'نجاح',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.surface,
      margin: const EdgeInsets.all(16),
      borderRadius: AppRadius.md,
      duration: const Duration(seconds: 3),
    );
  }

  static void error(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.surface,
      margin: const EdgeInsets.all(16),
      borderRadius: AppRadius.md,
      duration: const Duration(seconds: 4),
    );
  }

  static void info(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: AppColors.surface,
      margin: const EdgeInsets.all(16),
      borderRadius: AppRadius.md,
    );
  }
}
