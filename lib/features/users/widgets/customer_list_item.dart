import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../controllers/users_controller.dart';
import '../models/customer_model.dart';
import 'customer_form_dialog.dart';

class CustomerListItem extends StatelessWidget {
  const CustomerListItem({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              customer.fullName.isNotEmpty
                  ? customer.fullName.characters.first
                  : '?',
              style: AppTextStyles.h5.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.fullName, style: AppTextStyles.h6),
                const SizedBox(height: AppSpacing.xs),
                Text(customer.email, style: AppTextStyles.body2),
                const SizedBox(height: AppSpacing.xs),
                Text(customer.phoneNumber, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  controller.isPhoneLinked(customer)
                      ? 'الهاتف مربوط لتسجيل الدخول'
                      : 'الهاتف غير مربوط',
                  style: AppTextStyles.caption.copyWith(
                    color: controller.isPhoneLinked(customer)
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!controller.isPhoneLinked(customer))
            IconButton(
              tooltip: 'ربط الهاتف',
              onPressed: () => controller.linkCustomerPhone(customer),
              icon: const Icon(Icons.link, size: AppIconSize.md),
              color: AppColors.primary,
            ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'عميل',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'تعديل',
            onPressed: () => _openEdit(controller),
            icon: const Icon(Icons.edit_outlined, size: AppIconSize.md),
            color: AppColors.info,
          ),
          IconButton(
            tooltip: 'حذف',
            onPressed: () => _confirmDelete(controller),
            icon: const Icon(Icons.delete_outline, size: AppIconSize.md),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit(UsersController controller) async {
    controller.prepareEdit(customer);
    await Get.dialog<bool>(
      const CustomerFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete(UsersController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف المستخدم', style: AppTextStyles.h5),
        content: Text(
          'هل تريد حذف "${customer.fullName}"؟',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
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
      await controller.deleteCustomer(customer);
    }
  }
}
