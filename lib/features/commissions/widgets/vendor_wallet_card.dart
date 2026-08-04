import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../requests/widgets/status_badge.dart';
import '../models/vendor_wallet_model.dart';

class VendorWalletCard extends StatelessWidget {
  const VendorWalletCard({
    super.key,
    required this.entry,
    this.selected = false,
    this.onTap,
    this.onMarkSent,
    this.isMarkingSent = false,
  });

  final VendorWalletModel entry;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onMarkSent;
  final bool isMarkingSent;

  @override
  Widget build(BuildContext context) {
    final showMarkSent = entry.canMarkAsSent && onMarkSent != null;
    final accent = _accentColor(entry);

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? accent : AppColors.border,
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
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: accent,
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.productName.isEmpty
                          ? 'أرباح تاجر'
                          : entry.productName,
                      style: AppTextStyles.h6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormatUtils.format(entry.effectiveAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: entry.status),
            ],
          ),
          if (_statusHint(entry) != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _statusHint(entry)!,
              style: AppTextStyles.caption.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MiniStat(
                label: 'ربح التاجر',
                value: '${entry.amount}',
                emphasize: true,
                emphasizeColor: accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(label: 'سعر الطلب', value: '${entry.orderPrice}'),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'عمولة التطبيق',
                value: '${entry.appCommission}',
              ),
            ],
          ),
          if (entry.vendorId.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'التاجر: ${entry.vendorId}',
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showMarkSent && onTap == null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'ارسال الارباح للتاجر',
              icon: Icons.send_outlined,
              isLoading: isMarkingSent,
              isExpanded: true,
              onPressed: isMarkingSent ? null : onMarkSent,
            ),
          ],
        ],
      ),
    );

    final tappable = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: card,
            ),
          );

    if (!showMarkSent || onTap == null) return tappable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tappable,
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'ارسال الارباح للتاجر',
          icon: Icons.send_outlined,
          isLoading: isMarkingSent,
          isExpanded: true,
          onPressed: isMarkingSent ? null : onMarkSent,
        ),
      ],
    );
  }

  static Color _accentColor(VendorWalletModel entry) {
    if (entry.isRequestSent) return AppColors.warning;
    if (entry.isDone) return AppColors.success;
    if (entry.isPending) return AppColors.info;
    if (entry.isSent) return AppColors.secondary;
    return AppColors.primary;
  }

  static String? _statusHint(VendorWalletModel entry) {
    if (entry.isDone) {
      return 'محسوب في الإجمالي — يمكن إرسال الأرباح للتاجر';
    }
    if (entry.isRequestSent) return 'بانتظار إرسال الأرباح للتاجر';
    if (entry.isPending) return 'قيد الانتظار — غير محسوبة في الإجمالي';
    if (entry.isSent) return 'تم الإرسال — غير محسوبة في الإجمالي';
    return null;
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.emphasizeColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? emphasizeColor;

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
                color: emphasize
                    ? (emphasizeColor ?? AppColors.primary)
                    : AppColors.textPrimary,
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
