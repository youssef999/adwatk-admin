import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/vendors_controller.dart';
import '../widgets/vendor_form_dialog.dart';
import '../widgets/vendor_list_item.dart';

class VendorsPage extends StatelessWidget {
  const VendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VendorsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.applyRouteArguments();
    });

    return AppScaffold(
      title: 'البائعون',
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppButton(
            label: 'إضافة بائع',
            icon: Icons.storefront_outlined,
            onPressed: _openCreate,
          ),
        ),
      ],
      body: GetBuilder<VendorsController>(
        id: VendorsController.listId,
        builder: (controller) {
          if (controller.isLoading && controller.vendors.isEmpty) {
            return const AppLoader(message: 'جاري تحميل البائعين...');
          }

          if (controller.errorMessage != null && controller.vendors.isEmpty) {
            return AppErrorState(
              message: controller.errorMessage!,
              onRetry: controller.loadVendors,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.focusedVendorId != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'عرض بائع محدد: ${controller.focusedVendorId}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.clearVendorFocus,
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                ),
              ],
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'بحث باسم المحل أو البريد أو الهاتف...',
                  hintStyle: AppTextStyles.body2,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${controller.filteredVendors.length} بائع (worker / test_worker)',
                      style: AppTextStyles.body2,
                    ),
                  ),
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed: controller.loadVendors,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: controller.vendors.isEmpty
                    ? AppEmptyState(
                        title: 'لا يوجد بائعون',
                        subtitle: 'أضف بائعًا بدور worker أو test_worker',
                        icon: Icons.storefront_outlined,
                        actionLabel: 'إضافة بائع',
                        onAction: _openCreate,
                      )
                    : controller.filteredVendors.isEmpty
                        ? const AppEmptyState(
                            title: 'لا نتائج',
                            subtitle: 'جرّب كلمات بحث أخرى',
                            icon: Icons.search_off,
                          )
                        : ListView.separated(
                            itemCount: controller.filteredVendors.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              return VendorListItem(
                                vendor: controller.filteredVendors[index],
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

  Future<void> _openCreate() async {
    final controller = Get.find<VendorsController>();
    controller.prepareCreate();
    await Get.dialog<bool>(
      const VendorFormDialog(),
      barrierDismissible: false,
    );
  }
}
