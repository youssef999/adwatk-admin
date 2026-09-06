import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../../commissions/widgets/provider_commission_card.dart';
import '../controllers/requests_controller.dart';
import '../models/request_model.dart';
import 'offer_card.dart';
import 'accepted_offer_card.dart';
import 'shipment_offer_card.dart';
import 'status_badge.dart';

class RequestDetailPanel extends StatelessWidget {
  const RequestDetailPanel({
    super.key,
    this.showBack = false,
  });

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RequestsController>(
      id: RequestsController.detailId,
      builder: (controller) {
        final request = controller.selectedRequest;
        if (request == null) {
          return const AppEmptyState(
            title: 'اختر طلبًا',
            subtitle: 'حدد طلبًا من القائمة لعرض التفاصيل والعروض المرتبطة',
            icon: Icons.touch_app_outlined,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: controller.clearSelection,
                  icon: const Icon(Icons.arrow_forward, size: AppIconSize.md),
                  label: const Text('رجوع للقائمة'),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: controller.confirmDeleteSelectedRequest,
                icon: const Icon(
                  Icons.delete_outline,
                  size: AppIconSize.md,
                  color: AppColors.error,
                ),
                label: Text(
                  'حذف الطلب',
                  style: AppTextStyles.button.copyWith(color: AppColors.error),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _RequestHero(request: request),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoSection(request: request),
                  const SizedBox(height: AppSpacing.lg),
                  _ConnectionSummary(controller: controller),
                  if (request.hasShipmentOffer) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _EmbeddedShipmentSnapshot(request: request),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (controller.isLoadingRelations)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: AppLoader(message: 'جاري تحميل الارتباطات...'),
                    )
                  else if (controller.relationsError != null)
                    AppErrorState(
                      message: controller.relationsError!,
                      onRetry: () => controller.selectRequest(request),
                    )
                  else ...[
                    _SectionHeader(
                      title: 'العروض المقبولة',
                      count: controller.selectedAcceptedOffers.length,
                      subtitle:
                          'accepted_offers ↔ requestId + offerId',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (controller.selectedAcceptedOffers.isEmpty)
                      const AppEmptyState(
                        title: 'لا يوجد عرض مقبول',
                        subtitle:
                            'عندما يُقبل عرض سيظهر هنا مربوطًا بالطلب والعرض',
                        icon: Icons.verified_outlined,
                      )
                    else
                      ...controller.selectedAcceptedOffers.map(
                        (accepted) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AcceptedOfferCard(
                            accepted: accepted,
                            linkedOffer:
                                controller.offerById(accepted.offerId) ??
                                    controller.offerById(accepted.id),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionHeader(
                      title: 'عروض البائعين',
                      count: controller.selectedOffers.length,
                      subtitle: 'مرتبطة عبر offers.requestId',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (controller.selectedOffers.isEmpty)
                      const AppEmptyState(
                        title: 'لا توجد عروض بعد',
                        subtitle: 'لم يقدّم أي بائع عرضًا على هذا الطلب',
                        icon: Icons.local_offer_outlined,
                      )
                    else
                      ...controller.selectedOffers.map(
                        (offer) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: OfferCard(
                            offer: offer,
                            linkedShipmentsCount:
                                controller.shipmentCountForOffer(offer.id),
                            hasAcceptedRecord:
                                controller.isOfferAcceptedRecord(offer.id),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionHeader(
                      title: 'عمولات البائعين',
                      count: controller.selectedCommissions.length,
                      subtitle:
                          'provider_commission ↔ requestId + offerId + workerId',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (controller.selectedCommissions.isEmpty)
                      const AppEmptyState(
                        title: 'لا توجد عمولات لهذا الطلب',
                        subtitle:
                            'عند اكتمال البيع تظهر عمولة البائع هنا مربوطة بالعرض',
                        icon: Icons.payments_outlined,
                      )
                    else
                      ...controller.selectedCommissions.map(
                        (commission) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ProviderCommissionCard(
                            commission: commission,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionHeader(
                      title: 'عروض الشحن',
                      count: controller.selectedShipmentOffers.length,
                      subtitle:
                          'shipment_offers → offer + shippiment_stores',
                      color: AppColors.info,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (controller.selectedShipmentOffers.isEmpty)
                      const AppEmptyState(
                        title: 'لا توجد عروض شحن',
                        subtitle: 'لم يُربط أي شحن بهذا الطلب بعد',
                        icon: Icons.local_shipping_outlined,
                      )
                    else
                      ...controller.selectedShipmentOffers.map(
                        (shipment) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ShipmentOfferCard(
                            shipment: shipment,
                            linkedOffer:
                                controller.offerById(shipment.offerId),
                            store: controller.storeById(shipment.uid),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RequestHero extends StatelessWidget {
  const _RequestHero({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 8,
            child: !StorageUrl.isUsable(request.imageUrl)
                ? Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: AppIconSize.xl,
                      color: AppColors.textDisabled,
                    ),
                  )
                : AppNetworkImage(
                    url: request.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 900,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.partName.isEmpty ? 'طلب بدون اسم' : request.partName,
                        style: AppTextStyles.h4,
                      ),
                    ),
                    StatusBadge(status: request.status),
                  ],
                ),
                if (request.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(request.description, style: AppTextStyles.body2),
                ],
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Tag(label: request.carBrandLabel, icon: Icons.directions_car_outlined),
                    _Tag(label: request.carType, icon: Icons.category_outlined),
                    if (request.vin.isNotEmpty)
                      _Tag(label: 'VIN: ${request.vin}', icon: Icons.pin_outlined),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('تفاصيل الطلب', style: AppTextStyles.h6),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(label: 'تاريخ الإنشاء', value: DateFormatUtils.format(request.createdAt)),
          _InfoRow(label: 'عنوان العميل', value: request.userAddress.isEmpty ? '—' : request.userAddress),
          _InfoRow(
            label: 'الموقع',
            value: '${request.userLat.toStringAsFixed(5)}, ${request.userLng.toStringAsFixed(5)}',
          ),
          _InfoRow(label: 'معرّف العميل', value: request.uid.isEmpty ? '—' : request.uid),
          _InfoRow(label: 'معرّف الطلب', value: request.id),
          _InfoRow(
            label: 'إشعار مُرسل',
            value: request.notificationSent ? 'نعم' : 'لا',
          ),
        ],
      ),
    );
  }
}

class _ConnectionSummary extends StatelessWidget {
  const _ConnectionSummary({required this.controller});

  final RequestsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _SummaryStat(
            icon: Icons.local_offer_outlined,
            label: 'عروض',
            value: '${controller.selectedOffers.length}',
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          _SummaryStat(
            icon: Icons.verified_outlined,
            label: 'مقبولة',
            value: '${controller.selectedAcceptedOffers.length}',
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          _SummaryStat(
            icon: Icons.payments_outlined,
            label: 'عمولات',
            value: '${controller.selectedCommissions.length}',
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          _SummaryStat(
            icon: Icons.local_shipping_outlined,
            label: 'شحن',
            value: '${controller.selectedShipmentOffers.length}',
            color: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppIconSize.md),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.h5.copyWith(color: color),
            ),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.subtitle,
    this.color = AppColors.primary,
  });

  final String title;
  final int count;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(title, style: AppTextStyles.h5),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTextStyles.caption),
      ],
    );
  }
}

class _EmbeddedShipmentSnapshot extends StatelessWidget {
  const _EmbeddedShipmentSnapshot({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_added_outlined, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text('ملخص الشحن على الطلب', style: AppTextStyles.h6),
              const Spacer(),
              if (request.shipmentStatus != null)
                StatusBadge(status: request.shipmentStatus!),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'حقول مضمّنة داخل مستند الـ request (shipmentOfferId...)',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(label: 'shipmentOfferId', value: request.shipmentOfferId ?? '—'),
          _InfoRow(
            label: 'السعر',
            value: request.shipmentOfferPrice == null
                ? '—'
                : '${request.shipmentOfferPrice} د.ع',
          ),
          _InfoRow(
            label: 'الشاحن',
            value: request.shipmentShipperUid ?? '—',
          ),
          _InfoRow(
            label: 'التاريخ',
            value: DateFormatUtils.format(request.shipmentOfferAt),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.sm, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
