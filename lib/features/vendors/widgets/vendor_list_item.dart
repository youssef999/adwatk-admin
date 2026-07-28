import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../controllers/vendors_controller.dart';
import '../models/vendor_model.dart';
import 'vendor_form_dialog.dart';

class VendorListItem extends StatelessWidget {
  const VendorListItem({super.key, required this.vendor});

  final VendorModel vendor;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VendorsController>();
    final roleColor = vendor.role == UserRoles.testWorker
        ? AppColors.warning
        : AppColors.success;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.secondary,
                  size: AppIconSize.lg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.shopName, style: AppTextStyles.h6),
                    const SizedBox(height: AppSpacing.xs),
                    Text(vendor.email, style: AppTextStyles.body2),
                    const SizedBox(height: AppSpacing.xs),
                    Text(vendor.phoneNumber, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(vendor.address, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  vendor.role,
                  style: AppTextStyles.caption.copyWith(
                    color: roleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'العمولات والحوافز',
                onPressed: () => Get.toNamed(
                  AppRoutes.commissions,
                  arguments: {'workerId': vendor.uid},
                ),
                icon: const Icon(Icons.payments_outlined, size: AppIconSize.md),
                color: AppColors.primary,
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
                icon: const Icon(Icons.delete_outline, size: AppIconSize.md),
                color: AppColors.error,
              ),
            ],
          ),
          if (vendor.specializations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: vendor.specializations
                  .map(
                    (spec) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(spec, style: AppTextStyles.caption),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'الموقع: ${vendor.shopLat.toStringAsFixed(5)}, ${vendor.shopLng.toStringAsFixed(5)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit(VendorsController controller) async {
    controller.prepareEdit(vendor);
    await Get.dialog<bool>(
      const VendorFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete(VendorsController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف البائع', style: AppTextStyles.h5),
        content: Text(
          'هل تريد حذف "${vendor.shopName}"؟',
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
      await controller.deleteVendor(vendor);
    }
  }
}
