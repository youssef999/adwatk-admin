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
import '../../../shared/widgets/media/app_network_image.dart';
import '../controllers/requests_controller.dart';
import '../models/sale_part_model.dart';
import 'status_badge.dart';

class SalePartDetailPanel extends StatelessWidget {
  const SalePartDetailPanel({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RequestsController>(
      id: RequestsController.detailId,
      builder: (controller) {
        final part = controller.selectedSalePart;
        if (part == null) {
          return const AppEmptyState(
            title: 'اختر قطعة للبيع',
            subtitle: 'حدد عنصرًا من قائمة sale_parts لعرض التفاصيل',
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
            Expanded(
              child: ListView(
                children: [
                  _Hero(part: part),
                  const SizedBox(height: AppSpacing.lg),
                  _Info(part: part),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.part});

  final SalePartModel part;

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
            child: !StorageUrl.isUsable(part.imageUrl)
                ? Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: AppIconSize.xl,
                      color: AppColors.textDisabled,
                    ),
                  )
                : AppNetworkImage(
                    url: part.imageUrl,
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
                        part.partName.isEmpty ? 'بدون اسم' : part.partName,
                        style: AppTextStyles.h4,
                      ),
                    ),
                    StatusBadge(status: part.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${part.price} د.ع',
                  style: AppTextStyles.h5.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  part.description.isEmpty ? '—' : part.description,
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.part});

  final SalePartModel part;

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
          Text('تفاصيل القطعة', style: AppTextStyles.h6),
          const SizedBox(height: AppSpacing.md),
          _Row(label: 'الحالة', value: part.condition),
          _Row(label: 'الماركة', value: part.carBrandLabel),
          _Row(label: 'النوع', value: part.carType),
          _Row(label: 'البائع', value: part.sellerName),
          _Row(label: 'العنوان', value: part.sellerAddress),
          _Row(
            label: 'التاريخ',
            value: DateFormatUtils.format(part.createdAt),
          ),
          _Row(label: 'sale_part id', value: part.id),
          _Row(label: 'uid', value: part.uid),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

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
            width: 110,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
