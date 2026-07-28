import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.isEmpty ? '—' : status,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _colorFor(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
      case 'accepted':
      case 'delivered':
        return AppColors.success;
      case 'pending':
      case 'waiting':
        return AppColors.warning;
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return AppColors.error;
      case 'active':
      case 'in_progress':
      case 'new':
        return AppColors.info;
      default:
        return AppColors.secondary;
    }
  }
}
