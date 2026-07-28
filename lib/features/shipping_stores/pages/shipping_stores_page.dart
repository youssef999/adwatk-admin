import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/shipping_stores_controller.dart';
import '../widgets/shipping_store_form_dialog.dart';
import '../widgets/shipping_stores_table.dart';

class ShippingStoresPage extends StatelessWidget {
  const ShippingStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'متاجر الشحن',
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppButton(
            label: 'إضافة متجر',
            icon: Icons.add,
            onPressed: _openCreate,
          ),
        ),
      ],
      body: GetBuilder<ShippingStoresController>(
        id: ShippingStoresController.listId,
        builder: (controller) {
          if (controller.isLoading && controller.stores.isEmpty) {
            return const AppLoader(message: 'جاري تحميل متاجر الشحن...');
          }

          if (controller.errorMessage != null && controller.stores.isEmpty) {
            return AppErrorState(
              message: controller.errorMessage!,
              onRetry: controller.loadStores,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو البريد أو profileId...',
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
                      '${controller.filteredStores.length} متجر (shippiment_stores)',
                      style: AppTextStyles.body2,
                    ),
                  ),
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed: controller.loadStores,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: controller.stores.isEmpty
                    ? AppEmptyState(
                        title: 'لا توجد متاجر شحن',
                        subtitle: 'أضف متجر شحن جديد للبدء',
                        icon: Icons.local_shipping_outlined,
                        actionLabel: 'إضافة متجر',
                        onAction: _openCreate,
                      )
                    : controller.filteredStores.isEmpty
                        ? const AppEmptyState(
                            title: 'لا نتائج',
                            subtitle: 'جرّب كلمات بحث أخرى',
                            icon: Icons.search_off,
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              if (Breakpoints.isMobile(constraints.maxWidth)) {
                                return ListView.separated(
                                  itemCount: controller.filteredStores.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: AppSpacing.md),
                                  itemBuilder: (context, index) {
                                    return ShippingStoreMobileCard(
                                      store:
                                          controller.filteredStores[index],
                                    );
                                  },
                                );
                              }

                              return SingleChildScrollView(
                                child: ShippingStoresTable(
                                  stores: controller.filteredStores,
                                ),
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
    final controller = Get.find<ShippingStoresController>();
    controller.prepareCreate();
    await Get.dialog<bool>(
      const ShippingStoreFormDialog(),
      barrierDismissible: false,
    );
  }
}
