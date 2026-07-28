import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/users_controller.dart';

class CustomerFormDialog extends StatelessWidget {
  const CustomerFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UsersController>(
      id: UsersController.formId,
      builder: (controller) {
        final isEdit = controller.editingCustomer != null;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? 'تعديل مستخدم' : 'إضافة مستخدم',
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
                    AppTextField(
                      label: 'الاسم الكامل',
                      controller: controller.fullNameController,
                      hint: 'مثال: أحمد محمد',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'البريد الإلكتروني',
                      controller: controller.emailController,
                      hint: 'user@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'رقم الهاتف',
                      controller: controller.phoneController,
                      hint: '+9647xxxxxxxx',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'الدور: عميل (customer)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
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
          ),
        );
      },
    );
  }
}
