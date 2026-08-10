import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Toggle: ON → min wallet alert `value = 0` (no negative balance allowed).
class NegativeBalanceRestrictToggle extends StatelessWidget {
  const NegativeBalanceRestrictToggle({
    super.key,
    required this.restricted,
    required this.onChanged,
    this.enabled = true,
  });

  final bool restricted;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: restricted
            ? AppColors.warning.withValues(alpha: 0.08)
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: restricted
              ? AppColors.warning.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقييد الرصيد السالب',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  restricted
                      ? 'مفعّل — حد المحفظة = 0 (لا يُسمح بالسالب)'
                      : 'معطّل — يمكن تحديد حد سالب مخصص',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: restricted,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
