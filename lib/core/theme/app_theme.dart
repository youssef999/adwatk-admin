import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.cairo,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineMedium: AppTextStyles.h4,
        headlineSmall: AppTextStyles.h5,
        titleLarge: AppTextStyles.h6,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        labelSmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.cairo,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        error: AppColors.darkError,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: AppTextStyles.h5.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTextStyles.h6.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.darkTextSecondary),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.darkBackground),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dividerColor: AppColors.darkDivider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
