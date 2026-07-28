import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../controllers/banners_controller.dart';
import '../models/banner_model.dart';
import 'banner_form_dialog.dart';

class BannerListItem extends StatelessWidget {
  const BannerListItem({super.key, required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BannersController>();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: AppNetworkImage(
                url: banner.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                memCacheWidth: 800,
                errorWidget: Container(
                  color: AppColors.background,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textDisabled,
                    size: AppIconSize.xl,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'ترتيب ${banner.order}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
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
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit(BannersController controller) async {
    controller.prepareEdit(banner);
    await Get.dialog<bool>(
      const BannerFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete(BannersController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف البنر', style: AppTextStyles.h5),
        content: const Text(
          'هل أنت متأكد من حذف هذا البنر؟ لا يمكن التراجع عن هذه العملية.',
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
      await controller.deleteBanner(banner);
    }
  }
}
