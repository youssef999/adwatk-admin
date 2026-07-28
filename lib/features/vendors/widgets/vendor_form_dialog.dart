import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/vendors_controller.dart';

class VendorFormDialog extends StatelessWidget {
  const VendorFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VendorsController>(
      id: VendorsController.formId,
      builder: (controller) {
        final isEdit = controller.editingVendor != null;

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
                          isEdit ? 'تعديل بائع' : 'إضافة بائع',
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
                          AppTextField(
                            label: 'اسم المحل',
                            controller: controller.shopNameController,
                            hint: 'مثال: قطع غيار النخبة',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'البريد الإلكتروني',
                            controller: controller.emailController,
                            hint: 'vendor@email.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'رقم الهاتف',
                            controller: controller.phoneController,
                            hint: '+9647xxxxxxxx',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'العنوان',
                            controller: controller.addressController,
                            hint: 'المدينة / المنطقة',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'خط العرض (Lat)',
                                  controller: controller.latController,
                                  hint: '36.36',
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.\-]'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AppTextField(
                                  label: 'خط الطول (Lng)',
                                  controller: controller.lngController,
                                  hint: '42.40',
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.\-]'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'التخصصات',
                            controller: controller.specializationsController,
                            hint: 'American, German, Korean',
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'افصل بين التخصصات بفاصلة',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text('الدور', style: AppTextStyles.h6),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: [
                              ChoiceChip(
                                label: const Text('worker'),
                                selected:
                                    controller.selectedRole == UserRoles.worker,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                onSelected: controller.isSubmitting
                                    ? null
                                    : (_) =>
                                        controller.setRole(UserRoles.worker),
                              ),
                              ChoiceChip(
                                label: const Text('test_worker'),
                                selected: controller.selectedRole ==
                                    UserRoles.testWorker,
                                selectedColor:
                                    AppColors.warning.withValues(alpha: 0.2),
                                onSelected: controller.isSubmitting
                                    ? null
                                    : (_) => controller
                                        .setRole(UserRoles.testWorker),
                              ),
                            ],
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
