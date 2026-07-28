import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../../shipping_stores/models/shippiment_store_model.dart';
import '../models/offer_model.dart';
import '../models/shipment_offer_model.dart';
import 'status_badge.dart';

class ShipmentOfferCard extends StatelessWidget {
  const ShipmentOfferCard({
    super.key,
    required this.shipment,
    this.linkedOffer,
    this.store,
  });

  final ShipmentOfferModel shipment;
  final OfferModel? linkedOffer;
  final ShippimentStoreModel? store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StoreAvatar(store: store),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store?.name.isNotEmpty == true
                          ? store!.name
                          : (shipment.email.isNotEmpty
                              ? shipment.email
                              : 'شركة شحن'),
                      style: AppTextStyles.h6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      store?.profileId.isNotEmpty == true
                          ? store!.profileId
                          : shipment.uid,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: shipment.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.payments_outlined,
                  label: 'سعر الشحن',
                  value: '${shipment.shippingPrice} د.ع',
                  emphasize: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'حجم المركبة',
                  value: store?.vehicleSizeType.isNotEmpty == true
                      ? store!.vehicleSizeType
                      : '—',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoTile(
                  icon: Icons.star_outline,
                  label: 'التقييم',
                  value: store == null ? '—' : '${store!.rate}',
                ),
              ),
            ],
          ),
          if (linkedOffer != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link,
                    size: AppIconSize.sm,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'مرتبط بعرض: ${linkedOffer!.shopName.isEmpty ? linkedOffer!.workerName : linkedOffer!.shopName} · ${linkedOffer!.price} د.ع',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: linkedOffer!.status),
                ],
              ),
            ),
          ],
          if (shipment.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ملاحظات: ${shipment.notes}',
              style: AppTextStyles.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'تاريخ عرض الشحن: ${DateFormatUtils.format(shipment.createdAt)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  const _StoreAvatar({this.store});

  final ShippimentStoreModel? store;

  @override
  Widget build(BuildContext context) {
    final url = store?.profileImageUrl ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: 48,
        height: 48,
        child: !StorageUrl.isUsable(url)
            ? Container(
                color: AppColors.info.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.info,
                ),
              )
            : AppNetworkImage(
                url: url,
                fit: BoxFit.cover,
                memCacheWidth: 96,
                errorWidget: Container(
                  color: AppColors.info.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.info,
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppIconSize.sm,
                color: emphasize ? AppColors.info : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: emphasize ? AppColors.info : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
