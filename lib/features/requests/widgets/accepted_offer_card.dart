import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../models/accepted_offer_model.dart';
import '../models/offer_model.dart';

class AcceptedOfferCard extends StatelessWidget {
  const AcceptedOfferCard({
    super.key,
    required this.accepted,
    this.linkedOffer,
  });

  final AcceptedOfferModel accepted;
  final OfferModel? linkedOffer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
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
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.verified,
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
                      accepted.partName.isEmpty ? 'عرض مقبول' : accepted.partName,
                      style: AppTextStyles.h6,
                    ),
                    Text(
                      'تم القبول: ${DateFormatUtils.format(accepted.acceptedAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'accepted',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (StorageUrl.isUsable(accepted.requestImageUrl)) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: AppNetworkImage(
                  url: accepted.requestImageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _BlockTitle(title: 'الربط'),
          _LinkRow(
            label: 'requestId',
            value: accepted.requestId,
          ),
          _LinkRow(
            label: 'offerId',
            value: accepted.offerId,
            highlight: linkedOffer != null,
          ),
          if (linkedOffer != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'مطابق لعرض في offers: ${linkedOffer!.shopName.isEmpty ? linkedOffer!.workerName : linkedOffer!.shopName}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'لم يُعثر على العرض الأصلي في offers لهذا الطلب',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          _BlockTitle(title: 'العميل'),
          _InfoGrid(
            items: [
              _InfoItem('الاسم', accepted.customerName),
              _InfoItem('الهاتف', accepted.customerPhone),
              _InfoItem('البريد', accepted.customerEmail),
              _InfoItem('customerId', accepted.customerId),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _BlockTitle(title: 'المحل / البائع'),
          _InfoGrid(
            items: [
              _InfoItem('المحل', accepted.shopName),
              _InfoItem('الهاتف', accepted.shopPhone),
              _InfoItem('البريد', accepted.shopEmail),
              _InfoItem('العنوان', accepted.shopAddress),
              _InfoItem('shopId', accepted.shopId),
              _InfoItem(
                'السعر',
                '${accepted.price} د.ع',
                emphasize: true,
              ),
              _InfoItem('الحالة', accepted.condition),
              _InfoItem('الضمان', accepted.warrantyPeriod),
              _InfoItem('نوع السيارة', accepted.carType),
              _InfoItem('VIN', accepted.vin),
            ],
          ),
          if (accepted.shopSpecializations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: accepted.shopSpecializations
                  .map(
                    (spec) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(spec, style: AppTextStyles.caption),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (accepted.partDescription.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(accepted.partDescription, style: AppTextStyles.body2),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'إنشاء الطلب: ${DateFormatUtils.format(accepted.requestCreatedAt)} · إنشاء العرض: ${DateFormatUtils.format(accepted.offerCreatedAt)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _BlockTitle extends StatelessWidget {
  const _BlockTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: AppTextStyles.h6),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.caption.copyWith(
                color: highlight ? AppColors.success : AppColors.textPrimary,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (item) => SizedBox(
              width: 160,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.value.isEmpty ? '—' : item.value,
                      style: AppTextStyles.caption.copyWith(
                        color: item.emphasize
                            ? AppColors.success
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value, {this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;
}
