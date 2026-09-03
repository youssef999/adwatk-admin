import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/users_controller.dart';

class CustomerNoteDialog extends StatelessWidget {
  const CustomerNoteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UsersController>(
      id: UsersController.noteFormId,
      builder: (controller) {
        final customer = controller.noteCustomer;
        final submitting = controller.isSubmitting;
        final customerLabel = customer == null
            ? '—'
            : (customer.fullName.isNotEmpty
                ? customer.fullName
                : customer.email);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'إضافة ملاحظة للعميل',
                            style: AppTextStyles.h4,
                          ),
                        ),
                        IconButton(
                          onPressed: submitting ? null : () => Get.back(),
                          icon: const Icon(Icons.close, size: AppIconSize.md),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      customerLabel,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'العنوان (title)',
                      controller: controller.noteTitleController,
                      hint: 'مثال: ملاحظة مهمة',
                      enabled: !submitting,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'التفاصيل (details)',
                      controller: controller.noteDetailsController,
                      hint: 'اكتب الملاحظة هنا',
                      maxLines: 4,
                      enabled: !submitting,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'النوع (type)',
                      controller: controller.noteTypeController,
                      hint: 'noti',
                      enabled: !submitting,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'إلغاء',
                            variant: AppButtonVariant.outlined,
                            onPressed: submitting ? null : () => Get.back(),
                            isExpanded: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: 'حفظ الملاحظة',
                            icon: Icons.note_add_outlined,
                            isExpanded: true,
                            isLoading: submitting,
                            onPressed: submitting
                                ? null
                                : () async {
                                    final ok =
                                        await controller.submitCustomerNote();
                                    if (ok) Get.back(result: true);
                                  },
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
