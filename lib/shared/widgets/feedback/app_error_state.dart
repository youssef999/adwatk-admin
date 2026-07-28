import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../buttons/app_button.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppIconSize.xl * 1.5,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
                icon: Icons.refresh,
                variant: AppButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
