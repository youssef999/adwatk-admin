import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../requests/widgets/status_badge.dart';
import '../models/shipment_wallet_model.dart';

class ShipmentWalletCard extends StatelessWidget {
  const ShipmentWalletCard({
    super.key,
    required this.entry,
    this.selected = false,
    this.onTap,
    this.onMarkSent,
    this.isMarkingSent = false,
  });

  final ShipmentWalletModel entry;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onMarkSent;
  final bool isMarkingSent;

  @override
  Widget build(BuildContext context) {
    final showMarkSent = entry.isDone && onMarkSent != null;
    final accent = _accentColor(entry);
    final amountColor =
        entry.amount < 0 ? AppColors.error : accent;

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
                  Icons.local_shipping_outlined,
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
                      entry.shipmentCompanyName.isEmpty
                          ? 'شركة شحن'
                          : entry.shipmentCompanyName,
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
                label: 'المبلغ',
                value: '${entry.amount}',
                valueColor: amountColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'المنتج',
                value: entry.productName.isEmpty ? '—' : entry.productName,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'الطلب',
                value: entry.requestId.isEmpty ? '—' : entry.requestId,
              ),
            ],
          ),
          if (showMarkSent && onTap == null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'تم الإرسال',
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
          label: 'تم الإرسال',
          icon: Icons.send_outlined,
          isLoading: isMarkingSent,
          isExpanded: true,
          onPressed: isMarkingSent ? null : onMarkSent,
        ),
      ],
    );
  }

  static Color _accentColor(ShipmentWalletModel entry) {
    if (entry.isDone) return AppColors.success;
    if (entry.isPending) return AppColors.warning;
    if (entry.isSent) return AppColors.secondary;
    return AppColors.info;
  }

  static String? _statusHint(ShipmentWalletModel entry) {
    if (entry.isDone) return 'محسوب في الإجمالي — يمكن تحويله إلى sent';
    if (entry.isPending) return 'قيد الانتظار — غير محسوبة في الإجمالي';
    if (entry.isSent) return 'تم الإرسال — غير محسوبة في الإجمالي';
    return null;
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

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
                color: valueColor ?? AppColors.textPrimary,
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
