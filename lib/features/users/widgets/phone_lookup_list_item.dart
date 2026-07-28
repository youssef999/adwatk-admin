import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../controllers/users_controller.dart';
import '../models/phone_lookup_model.dart';
import 'phone_lookup_form_dialog.dart';

class PhoneLookupListItem extends StatelessWidget {
  const PhoneLookupListItem({super.key, required this.lookup});

  final PhoneLookupModel lookup;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final matched = controller.customerForLookup(lookup);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
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
              Icons.phone_iphone,
              color: AppColors.primary,
              size: AppIconSize.md,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lookup.phone, style: AppTextStyles.h6),
                const SizedBox(height: AppSpacing.xs),
                Text(lookup.email, style: AppTextStyles.body2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  matched != null
                      ? 'مرتبط: ${matched.fullName}'
                      : 'لا يوجد مستخدم مطابق في القائمة',
                  style: AppTextStyles.caption.copyWith(
                    color: matched != null
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تعديل',
            onPressed: () => _openEdit(controller),
            icon: const Icon(Icons.edit_outlined, size: AppIconSize.md),
            color: AppColors.info,
          ),
          IconButton(
            tooltip: 'حذف',
            onPressed: () => _confirmDelete(controller),
            icon: const Icon(Icons.link_off, size: AppIconSize.md),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit(UsersController controller) async {
    controller.preparePhoneEdit(lookup);
    await Get.dialog<bool>(
      const PhoneLookupFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete(UsersController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف ربط الهاتف', style: AppTextStyles.h5),
        content: Text(
          'حذف الربط لـ ${lookup.phone}؟ لن يتمكن المستخدم من الدخول بالهاتف حتى يُعاد الربط.',
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
      await controller.deletePhoneLookup(lookup);
    }
  }
}
