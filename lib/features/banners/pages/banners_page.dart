import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/banners_controller.dart';
import '../widgets/banner_form_dialog.dart';
import '../widgets/banner_list_item.dart';

class BannersPage extends StatelessWidget {
  const BannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'إدارة البنرات',
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppButton(
            label: 'إضافة بنر',
            icon: Icons.add,
            onPressed: () => _openCreate(context),
          ),
        ),
      ],
      body: GetBuilder<BannersController>(
        id: BannersController.listId,
        builder: (controller) {
          if (controller.isLoading && controller.banners.isEmpty) {
            return const AppLoader(message: 'جاري تحميل البنرات...');
          }

          if (controller.errorMessage != null && controller.banners.isEmpty) {
            return AppErrorState(
              message: controller.errorMessage!,
              onRetry: controller.loadBanners,
            );
          }

          if (controller.banners.isEmpty) {
            return AppEmptyState(
              title: 'لا توجد بنرات بعد',
              subtitle: 'ابدأ بإضافة بنر جديد للعرض في التطبيق',
              icon: Icons.image_outlined,
              actionLabel: 'إضافة بنر',
              onAction: () => _openCreate(context),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${controller.banners.length} بنر',
                      style: AppTextStyles.body2,
                    ),
                  ),
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed: controller.loadBanners,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = Breakpoints.isDesktop(width)
                        ? 3
                        : Breakpoints.isTablet(width)
                            ? 2
                            : 1;

                    return GridView.builder(
                      itemCount: controller.banners.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 1.45,
                      ),
                      itemBuilder: (context, index) {
                        return BannerListItem(
                          banner: controller.banners[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final controller = Get.find<BannersController>();
    controller.prepareCreate();
    await Get.dialog<bool>(
      const BannerFormDialog(),
      barrierDismissible: false,
    );
  }
}
