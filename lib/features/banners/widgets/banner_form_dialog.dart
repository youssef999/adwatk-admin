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
import '../controllers/banners_controller.dart';

class BannerFormDialog extends StatelessWidget {
  const BannerFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannersController>(
      id: BannersController.formId,
      builder: (controller) {
        final isEdit = controller.editingBanner != null;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEdit ? 'تعديل البنر' : 'إضافة بنر جديد',
                          style: AppTextStyles.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(result: false),
                        icon: const Icon(Icons.close, size: AppIconSize.md),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ImagePickerArea(controller: controller),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'الترتيب',
                    controller: controller.orderController,
                    hint: 'مثال: 1',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                          label: isEdit ? 'حفظ التعديلات' : 'إضافة',
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

class _ImagePickerArea extends StatelessWidget {
  const _ImagePickerArea({required this.controller});

  final BannersController controller;

  @override
  Widget build(BuildContext context) {
    final bytes = controller.selectedImageBytes;
    final existingUrl = controller.editingBanner?.imageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('صورة البنر', style: AppTextStyles.h6),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: controller.isSubmitting ? null : controller.pickImage,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(bytes, fit: BoxFit.cover),
                      _OverlayHint(
                        label: controller.selectedImageName ?? 'صورة جديدة',
                        onClear: controller.clearSelectedImage,
                      ),
                    ],
                  )
                : StorageUrl.isUsable(existingUrl)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          AppNetworkImage(
                            url: existingUrl,
                            fit: BoxFit.cover,
                            errorWidget: const _EmptyPicker(),
                          ),
                          const _OverlayHint(label: 'اضغط لتغيير الصورة'),
                        ],
                      )
                    : const _EmptyPicker(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'يتم ضغط الصورة تلقائيًا قبل الرفع إلى Firebase Storage',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _EmptyPicker extends StatelessWidget {
  const _EmptyPicker();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: AppIconSize.xl, color: AppColors.textDisabled),
          SizedBox(height: AppSpacing.sm),
          Text('اختر صورة البنر', style: AppTextStyles.body2),
        ],
      ),
    );
  }
}

class _OverlayHint extends StatelessWidget {
  const _OverlayHint({required this.label, this.onClear});

  final String label;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.textPrimary.withValues(alpha: 0.65),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(color: AppColors.surface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, color: AppColors.surface, size: AppIconSize.sm),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
