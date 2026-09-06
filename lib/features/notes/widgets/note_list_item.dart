import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../controllers/notes_controller.dart';
import '../models/note_banner_model.dart';

class NoteListItem extends StatelessWidget {
  const NoteListItem({super.key, required this.note});

  final NoteBannerModel note;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotesController>();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title.isEmpty ? '—' : note.title,
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      note.details.isEmpty ? '—' : note.details,
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: () => _confirmDelete(controller),
                icon: const Icon(Icons.delete_outline, size: AppIconSize.md),
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Chip(
                label: note.typeLabelAr,
                color: AppColors.primary,
              ),
              _Chip(
                label: note.toLabelAr,
                color: AppColors.info,
              ),
              Text(
                DateFormatUtils.format(note.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(NotesController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف الملاحظة', style: AppTextStyles.h5),
        content: Text(
          'هل تريد حذف "${note.title}"؟',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'حذف',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteNote(note);
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
