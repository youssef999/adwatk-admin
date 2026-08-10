import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/commissions_controller.dart';
import '../widgets/commissions_detail_panel.dart';

class CommissionsDetailPage extends StatelessWidget {
  const CommissionsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CommissionsController>()) {
      return AppScaffold(
        title: 'تفاصيل العمولة',
        body: AppEmptyState(
          title: 'لا توجد بيانات',
          subtitle: 'ارجع لقائمة العمولات واختر عنصرًا',
          icon: Icons.hub_outlined,
          actionLabel: 'رجوع',
          onAction: () => Get.back(),
        ),
      );
    }

    final controller = Get.find<CommissionsController>();

    return AppScaffold(
      title: _titleFor(controller),
      actions: [
        IconButton(
          tooltip: 'رجوع',
          onPressed: () {
            controller.clearSelection();
            Get.back();
          },
          icon: const Icon(Icons.close, size: AppIconSize.lg),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      body: GetBuilder<CommissionsController>(
        id: CommissionsController.detailId,
        builder: (controller) {
          if (controller.selectedProfitTrans == null &&
              controller.selectedVendorWallet == null &&
              controller.selectedShipmentWallet == null &&
              controller.selectedShipmentMoneyRequest == null &&
              controller.selectedVendorMoneyRequest == null) {
            return AppEmptyState(
              title: 'لا توجد تفاصيل',
              subtitle: 'اختر عنصرًا من قائمة العمولات والأرباح',
              icon: Icons.hub_outlined,
              actionLabel: 'رجوع للقائمة',
              onAction: () => Get.back(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () {
                    controller.clearSelection();
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: AppIconSize.md,
                  ),
                  label: Text(
                    'رجوع للقائمة',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: const CommissionsDetailPanel(embedded: true),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _titleFor(CommissionsController controller) {
    if (controller.selectedProfitTrans != null) return 'تفاصيل ربح التطبيق';
    if (controller.selectedVendorWallet != null) return 'تفاصيل أرباح التاجر';
    if (controller.selectedShipmentWallet != null) {
      return 'تفاصيل معاملة الشحن';
    }
    if (controller.selectedShipmentMoneyRequest != null) {
      return 'تفاصيل طلب سحب الشحن';
    }
    if (controller.selectedVendorMoneyRequest != null) {
      return 'تفاصيل طلب سحب التاجر';
    }
    return 'تفاصيل العمولة';
  }
}
