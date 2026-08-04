import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../requests/widgets/status_badge.dart';
import '../models/app_profit_trans_model.dart';

class AppProfitTransCard extends StatelessWidget {
  const AppProfitTransCard({
    super.key,
    required this.transaction,
    this.selected = false,
    this.onTap,
  });

  final AppProfitTransModel transaction;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.secondary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? AppColors.secondary : AppColors.border,
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
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.secondary,
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _paymentTypeLabel(transaction.paymentType),
                      style: AppTextStyles.h6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormatUtils.format(transaction.effectiveAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: transaction.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MiniStat(
                label: 'الربح',
                value: '${transaction.amount}',
                emphasize: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'الطلب',
                value: transaction.requestId.isEmpty
                    ? '—'
                    : transaction.requestId,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'الطلبية',
                value: transaction.orderId.isEmpty
                    ? '—'
                    : transaction.orderId,
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

  static String _paymentTypeLabel(String type) {
    switch (type.trim().toLowerCase()) {
      case 'cash_payment':
        return 'دفع نقدي';
      case 'wallet_payment':
        return 'دفع من المحفظة';
      case 'online_payment':
      case 'card_payment':
        return 'دفع إلكتروني';
      case '':
        return 'معاملة ربح';
      default:
        return type;
    }
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

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
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: emphasize ? AppColors.secondary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
