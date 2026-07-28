import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outlined, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    final child = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label, style: AppTextStyles.button.copyWith(color: _foreground)),
        ],
      ],
    );

    final button = switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _background,
            foregroundColor: _foreground,
            disabledBackgroundColor: AppColors.textDisabled,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
          ),
          child: child,
        ),
      AppButtonVariant.outlined || AppButtonVariant.secondary || AppButtonVariant.ghost =>
        OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: _foreground,
            backgroundColor: variant == AppButtonVariant.secondary
                ? AppColors.secondary.withValues(alpha: 0.06)
                : Colors.transparent,
            side: variant == AppButtonVariant.ghost
                ? BorderSide.none
                : BorderSide(color: _borderColor),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: child,
        ),
    };

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Color get _background {
    return switch (variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.danger => AppColors.error,
      _ => AppColors.surface,
    };
  }

  Color get _foreground {
    return switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => AppColors.surface,
      AppButtonVariant.secondary => AppColors.secondary,
      AppButtonVariant.outlined => AppColors.primary,
      AppButtonVariant.ghost => AppColors.textSecondary,
    };
  }

  Color get _borderColor {
    return switch (variant) {
      AppButtonVariant.outlined => AppColors.primary,
      AppButtonVariant.secondary => AppColors.border,
      _ => AppColors.border,
    };
  }
}
