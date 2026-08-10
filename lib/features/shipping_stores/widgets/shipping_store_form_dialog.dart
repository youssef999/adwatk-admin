import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
