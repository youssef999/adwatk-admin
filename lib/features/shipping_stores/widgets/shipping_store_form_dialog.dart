import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/maps_launcher.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../controllers/shipping_stores_controller.dart';
import '../models/shippiment_store_model.dart';

class ShippingStoreFormDialog extends StatelessWidget {
  const ShippingStoreFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShippingStoresController>(
      id: ShippingStoresController.formId,
      builder: (controller) {
        final isEdit = controller.editingStore != null;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEdit ? 'تعديل متجر شحن' : 'إضافة متجر شحن',
                          style: AppTextStyles.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(result: false),
                        icon: const Icon(Icons.close, size: AppIconSize.md),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ImagePicker(controller: controller),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            label: 'اسم المتجر',
                            controller: controller.nameController,
                            hint: 'مثال: شركة النقل السريع',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'البريد الإلكتروني',
                            controller: controller.emailController,
                            hint: 'store@email.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'الحد الأقصى في السالب',
                            controller: controller.minWalletAlertController,
                            hint: 'مثال: 50000',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,\-]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'معرّف الملف (profileId)',
                            controller: controller.profileIdController,
                            hint: 'CMP-xxxxxxxxx',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'التقييم (rate)',
                            controller: controller.rateController,
                            hint: '0 - 5',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text('حجم المركبة', style: AppTextStyles.h6),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: ShippimentStoreModel.vehicleSizeTypes
                                .map(
                                  (type) => ChoiceChip(
                                    label: Text(type),
                                    selected:
                                        controller.vehicleSizeType == type,
                                    selectedColor: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    onSelected: controller.isSubmitting
                                        ? null
                                        : (_) => controller
                                            .setVehicleSizeType(type),
                                  ),
                                )
                                .toList(),
                          ),
                          if (controller.editingStore != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _StoreExtraDetails(store: controller.editingStore!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'إلغاء',
                          onPressed: controller.isSubmitting
                              ? null
                              : () => Get.back(result: false),
                          variant: AppButtonVariant.outlined,
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          label: isEdit ? 'حفظ' : 'إضافة',
                          onPressed: controller.isSubmitting
                              ? null
                              : () async {
                                  final ok = await controller.submitForm();
                                  if (ok) Get.back(result: true);
                                },
                          isLoading: controller.isSubmitting,
                          isExpanded: true,
                          icon: isEdit ? Icons.save_outlined : Icons.add,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({required this.controller});

  final ShippingStoresController controller;

  @override
  Widget build(BuildContext context) {
    final bytes = controller.selectedImageBytes;
    final existingUrl = controller.editingStore?.profileImageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('صورة الملف', style: AppTextStyles.h6),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: controller.isSubmitting ? null : controller.pickImage,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : StorageUrl.isUsable(existingUrl)
                    ? AppNetworkImage(
                        url: existingUrl,
                        fit: BoxFit.cover,
                        errorWidget: const _EmptyImage(),
                      )
                    : const _EmptyImage(),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'يتم ضغط الصورة قبل الرفع إلى Firebase Storage',
          style: AppTextStyles.caption,
        ),
        if (bytes != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: controller.clearSelectedImage,
              child: const Text('إزالة الصورة المختارة'),
            ),
          ),
      ],
    );
  }
}

class _EmptyImage extends StatelessWidget {
  const _EmptyImage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: AppIconSize.xl,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: AppSpacing.sm),
          Text('اختر صورة البروفايل', style: AppTextStyles.body2),
        ],
      ),
    );
  }
}

class _StoreExtraDetails extends StatelessWidget {
  const _StoreExtraDetails({required this.store});

  final ShippimentStoreModel store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('بيانات المركبة والموقع', style: AppTextStyles.h6),
          const SizedBox(height: AppSpacing.md),
          if (StorageUrl.isUsable(store.vehicleImageUrl)) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                height: 120,
                child: AppNetworkImage(
                  url: store.vehicleImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _DetailRow(
            label: 'اسم المركبة',
            value: store.vehicleName.isEmpty ? '—' : store.vehicleName,
          ),
          _DetailRow(
            label: 'اسم السائق',
            value: store.vehicleDriverName.isEmpty
                ? '—'
                : store.vehicleDriverName,
          ),
          _DetailRow(
            label: 'نوع المركبة',
            value: store.vehicleType.isEmpty ? '—' : store.vehicleType,
          ),
          _DetailRow(
            label: 'الرقم المميز',
            value: store.vehicleDistinctiveNumber.isEmpty
                ? '—'
                : store.vehicleDistinctiveNumber,
          ),
          _DetailRow(
            label: 'تحديث الموقع',
            value: DateFormatUtils.format(store.locationUpdatedAt),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (store.hasLocation)
            AppButton(
              label: 'فتح الموقع على خرائط جوجل',
              icon: Icons.map_outlined,
              variant: AppButtonVariant.outlined,
              isExpanded: true,
              onPressed: () => MapsLauncher.openLatLng(
                lat: store.lat!,
                lng: store.lng!,
              ),
            )
          else
            Text(
              'لا يوجد موقع محفوظ',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          Text(value, style: AppTextStyles.body2),
        ],
      ),
    );
  }
}
