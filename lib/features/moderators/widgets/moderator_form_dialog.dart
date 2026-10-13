import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/moderators_controller.dart';

class ModeratorFormDialog extends StatelessWidget {
  const ModeratorFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ModeratorsController>(
      id: ModeratorsController.formId,
      builder: (controller) {
        final isEdit = controller.editing != null;
        final passwordRequired = controller.passwordRequired;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
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
                            isEdit ? 'تعديل مشرف' : 'إضافة مشرف شحن',
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
                      'المشرف يرى أقسام الشحن فقط: متاجر الشحن، معاملات المحافظ وطلبات السحب.',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'اسم المشرف',
                      controller: controller.nameController,
                      hint: 'مثال: أحمد علي',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'البريد الإلكتروني',
                      controller: controller.emailController,
                      hint: 'moderator@adwatk.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: passwordRequired
                          ? 'كلمة المرور'
                          : 'كلمة مرور جديدة (اختياري)',
                      controller: controller.passwordController,
                      hint: passwordRequired
                          ? '6 أحرف على الأقل'
                          : 'اتركها فارغة للإبقاء على الحالية',
                      obscureText: controller.obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: controller.togglePasswordVisibility,
                        icon: Icon(
                          controller.obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: AppIconSize.md,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'لأسباب أمنية لا تُعرض كلمة المرور بعد الحفظ.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: controller.formActive,
                      activeThumbColor: AppColors.success,
                      onChanged: controller.setFormActive,
                      title: Text('الحساب مفعّل', style: AppTextStyles.h6),
                      subtitle: Text(
                        'عند الإيقاف يُمنع المشرف من الدخول فورًا',
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: isEdit ? 'حفظ التعديلات' : 'إضافة المشرف',
                      icon: isEdit ? Icons.save_outlined : Icons.add,
                      isLoading: controller.isSubmitting,
                      isExpanded: true,
                      onPressed: controller.isSubmitting
                          ? null
                          : () async {
                              final ok = await controller.submit();
                              if (ok) Get.back(result: true);
                            },
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
