import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/deep_link_navigation.dart';
import '../models/provider_commission_model.dart';

class ProviderCommissionCard extends StatelessWidget {
  const ProviderCommissionCard({
    super.key,
    required this.commission,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  final ProviderCommissionModel commission;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hasRequest = commission.requestId.trim().isNotEmpty;
    final hasOffer = commission.offerId.trim().isNotEmpty;
    final hasVendor = commission.workerId.trim().isNotEmpty;

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.payments_outlined,
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
                      commission.shopName.isEmpty
                          ? 'بائع'
                          : commission.shopName,
                      style: AppTextStyles.h6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormatUtils.format(commission.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                '${commission.commissionPercent}%',
                style: AppTextStyles.h6.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MiniStat(label: 'السعر', value: '${commission.price}'),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'عمولة التطبيق',
                value: '${commission.appCommission}',
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'عمولة البائع',
                value: '${commission.providerCommission}',
                emphasize: true,
              ),
            ],
          ),
          if (!compact) ...[
            if (hasRequest) ...[
              const SizedBox(height: AppSpacing.md),
              _LinkChip(
                icon: Icons.assignment_outlined,
                label: 'طلب',
                value: commission.requestId,
                onOpen: () => DeepLinkNavigation.openRequest(
                  requestId: commission.requestId,
                  offerId: hasOffer ? commission.offerId : null,
                ),
              ),
            ],
            if (hasOffer) ...[
              const SizedBox(height: AppSpacing.sm),
              _LinkChip(
                icon: Icons.local_offer_outlined,
                label: 'عرض',
                value: commission.offerId,
                onOpen: hasRequest
                    ? () => DeepLinkNavigation.openRequest(
                          requestId: commission.requestId,
                          offerId: commission.offerId,
                        )
                    : null,
              ),
            ],
            if (hasVendor) ...[
              const SizedBox(height: AppSpacing.sm),
              _LinkChip(
                icon: Icons.storefront_outlined,
                label: 'بائع',
                value: commission.workerId,
                onOpen: () => DeepLinkNavigation.openVendor(
                  vendorId: commission.workerId,
                ),
              ),
            ],
          ],
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
                color: emphasize ? AppColors.primary : AppColors.textPrimary,
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

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.label,
    required this.value,
    this.onOpen,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppIconSize.sm, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text('$label: ', style: AppTextStyles.caption),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.caption.copyWith(
                    color: onOpen != null
                        ? AppColors.info
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration:
                        onOpen != null ? TextDecoration.underline : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onOpen != null)
                const Icon(
                  Icons.open_in_new,
                  size: AppIconSize.sm,
                  color: AppColors.info,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
