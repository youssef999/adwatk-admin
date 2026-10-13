import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../models/moderator_model.dart';

class ModeratorListItem extends StatelessWidget {
  const ModeratorListItem({
    super.key,
    required this.moderator,
    required this.isToggling,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  final ModeratorModel moderator;
  final bool isToggling;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.primary,
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moderator.name.isEmpty ? '—' : moderator.name,
                  style: AppTextStyles.h6,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  moderator.email,
                  style: AppTextStyles.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusChip(moderator: moderator),
                    Text(
                      'أضيف: ${DateFormatUtils.format(moderator.createdAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: moderator.active,
                activeThumbColor: AppColors.success,
                onChanged: isToggling ? null : (_) => onToggleActive(),
              ),
              Text(
                moderator.active ? 'مفعّل' : 'موقوف',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          IconButton(
            tooltip: 'تعديل',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: AppIconSize.md),
          ),
          IconButton(
            tooltip: 'حذف',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              size: AppIconSize.md,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.moderator});

  final ModeratorModel moderator;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (moderator) {
      ModeratorModel(isReady: true) => ('الحساب جاهز للدخول', AppColors.success),
      ModeratorModel(hasError: true) => (
          'خطأ: ${_errorLabel(moderator.syncError)}',
          AppColors.error,
        ),
      _ => ('جاري تفعيل الحساب...', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _errorLabel(String code) {
    return switch (code) {
      'email-already-exists' =>
        'البريد مستخدم لحساب آخر في التطبيق، استخدم بريدًا مختلفًا',
      'invalid-email' => 'البريد الإلكتروني غير صالح',
      'weak-password' || 'invalid-password' =>
        'كلمة المرور ضعيفة (6 أحرف على الأقل) — عدّل وأدخل كلمة جديدة',
      'password-required' => 'أدخل كلمة مرور من زر التعديل',
      _ => code.isEmpty ? 'غير معروف' : code,
    };
  }
}
