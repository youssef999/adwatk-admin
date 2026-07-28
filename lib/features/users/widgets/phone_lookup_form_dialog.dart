import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/users_controller.dart';

class PhoneLookupFormDialog extends StatelessWidget {
  const PhoneLookupFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UsersController>(
      id: UsersController.phoneFormId,
      builder: (controller) {
        final isEdit = controller.editingPhoneLookup != null;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
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
                          isEdit ? 'تعديل ربط الهاتف' : 'ربط هاتف بمستخدم',
                          style: AppTextStyles.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(result: false),
                        icon: const Icon(Icons.close, size: AppIconSize.md),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'رقم الهاتف هو مفتاح المستند في phone_lookup ويُستخدم لتسجيل الدخول.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'رقم الهاتف',
                    controller: controller.lookupPhoneController,
                    hint: '+9647xxxxxxxx',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'البريد الإلكتروني',
                    controller: controller.lookupEmailController,
                    hint: 'user@email.com',
                    keyboardType: TextInputType.emailAddress,
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
                          label: 'حفظ',
                          onPressed: controller.isSubmitting
                              ? null
                              : () async {
                                  final ok =
                                      await controller.submitPhoneLookup();
                                  if (ok) Get.back(result: true);
                                },
                          isLoading: controller.isSubmitting,
                          isExpanded: true,
                          icon: Icons.link,
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
