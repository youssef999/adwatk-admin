import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../requests/widgets/status_badge.dart';
import '../models/incentive_request_model.dart';

class IncentiveRequestCard extends StatelessWidget {
  const IncentiveRequestCard({
    super.key,
    required this.incentive,
    this.selected = false,
    this.onTap,
  });

  final IncentiveRequestModel incentive;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.card_giftcard_outlined,
                  color: AppColors.success,
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incentive.shopName.isEmpty
                          ? 'طلب حافز'
                          : incentive.shopName,
                      style: AppTextStyles.h6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormatUtils.format(incentive.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: incentive.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Stat(label: 'الحافز', value: '${incentive.incentiveAmount}'),
              const SizedBox(width: AppSpacing.sm),
              _Stat(label: 'النسبة', value: '${incentive.incentivePercent}%'),
              const SizedBox(width: AppSpacing.sm),
              _Stat(label: 'المبيعات', value: '${incentive.salesCount}'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'إجمالي عمولة التطبيق: ${incentive.totalAppCommission} · '
            '${incentive.commissionDocIds.length} عمولة مرتبطة',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: AppIconSize.sm,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'workerId: ${incentive.workerId.isEmpty ? '—' : incentive.workerId}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: content,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(
              value,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
