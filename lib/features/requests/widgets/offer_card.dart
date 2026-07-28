import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../models/offer_model.dart';
import 'status_badge.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    this.linkedShipmentsCount = 0,
    this.hasAcceptedRecord = false,
  });

  final OfferModel offer;
  final int linkedShipmentsCount;
  final bool hasAcceptedRecord;

  @override
  Widget build(BuildContext context) {
    final highlighted = offer.isAccepted || hasAcceptedRecord;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.success.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlighted
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.shopName.isEmpty ? offer.workerName : offer.shopName,
                      style: AppTextStyles.h6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      offer.workerName,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: offer.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MetaChip(
                icon: Icons.payments_outlined,
                label: _formatPrice(offer.price),
                emphasize: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MetaChip(
                icon: Icons.verified_outlined,
                label: offer.condition.isEmpty ? '—' : offer.condition,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MetaChip(
                icon: Icons.shield_outlined,
                label: offer.warrantyPeriod.isEmpty
                    ? 'بدون ضمان'
                    : offer.warrantyPeriod,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'تاريخ العرض: ${DateFormatUtils.format(offer.createdAt)}',
            style: AppTextStyles.caption,
          ),
          if (linkedShipmentsCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: AppIconSize.sm,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$linkedShipmentsCount عرض شحن مرتبط',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (hasAcceptedRecord) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.verified,
                  size: AppIconSize.sm,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'موجود في accepted_offers',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(num price) {
    final value = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${buffer.toString()} د.ع';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppIconSize.sm,
              color: emphasize ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: emphasize ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
