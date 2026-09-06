import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/notes_controller.dart';
import '../models/note_audience.dart';
import '../models/note_type.dart';

class NoteFormDialog extends StatelessWidget {
  const NoteFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotesController>(
      id: NotesController.formId,
      builder: (controller) {
        final submitting = controller.isSubmitting;

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
                            'إضافة ملاحظة',
                            style: AppTextStyles.h4,
                          ),
                        ),
                        IconButton(
                          onPressed: submitting ? null : () => Get.back(),
                          icon: const Icon(Icons.close, size: AppIconSize.md),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'العنوان (title)',
                      controller: controller.titleController,
                      hint: 'مثال: ملاحظة مهمة',
                      enabled: !submitting,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'التفاصيل (details)',
                      controller: controller.detailsController,
                      hint: 'اكتب الملاحظة هنا',
                      maxLines: 4,
                      enabled: !submitting,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'النوع (type)',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final value in NoteType.values)
                          ChoiceChip(
                            label: Text(NoteType.labelAr(value)),
                            selected: controller.noteType == value,
                            onSelected: submitting
                                ? null
                                : (_) => controller.setNoteType(value),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.18),
                            labelStyle: AppTextStyles.caption.copyWith(
                              color: controller.noteType == value
                                  ? AppColors.primaryDark
                                  : AppColors.textPrimary,
                              fontWeight: controller.noteType == value
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: controller.noteType == value
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                            backgroundColor: AppColors.surface,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'إلى (to)',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final value in NoteAudience.values)
                          ChoiceChip(
                            label: Text(NoteAudience.labelAr(value)),
                            selected: controller.noteTo == value,
                            onSelected: submitting
                                ? null
                                : (_) => controller.setNoteTo(value),
                            selectedColor:
                                AppColors.info.withValues(alpha: 0.18),
                            labelStyle: AppTextStyles.caption.copyWith(
                              color: controller.noteTo == value
                                  ? AppColors.info
                                  : AppColors.textPrimary,
                              fontWeight: controller.noteTo == value
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: controller.noteTo == value
                                  ? AppColors.info
                                  : AppColors.border,
                            ),
                            backgroundColor: AppColors.surface,
                          ),
                      ],
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
                            label: 'حفظ',
                            icon: Icons.note_add_outlined,
                            isExpanded: true,
                            isLoading: submitting,
                            onPressed: submitting
                                ? null
                                : () async {
                                    final ok = await controller.submitNote();
                                    if (!ok) return;
                                    Get.back(result: true);
                                    AppSnackbar.success(
                                      'تمت إضافة الملاحظة بنجاح.',
                                    );
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
