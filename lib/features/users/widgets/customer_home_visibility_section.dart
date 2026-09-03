import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/users_controller.dart';

class HomeVisibilitySection extends StatelessWidget {
  const HomeVisibilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UsersController>(
      id: UsersController.listId,
      builder: (controller) {
        final settings = controller.currentGlobalViewInHome;
        final isUpdating = controller.isUpdatingGlobalViewInHome;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: AppIconSize.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'التحكم العام بعرض الصفحة الرئيسية',
                      style: AppTextStyles.body1,
                    ),
                  ),
                  if (isUpdating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _SwitchRow(
                title: 'عرض المتاجر',
                value: settings.showStores,
                enabled: !isUpdating,
                onChanged: controller.setGlobalHomeStoresVisibility,
              ),
              const SizedBox(height: AppSpacing.xs),
              _SwitchRow(
                title: 'عرض عروض التطبيق',
                value: settings.showClientOffers,
                enabled: !isUpdating,
                onChanged: controller.setGlobalHomeOffersVisibility,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value ? 'مفعّل' : 'مخفي',
            style: AppTextStyles.caption.copyWith(
              color: value ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
