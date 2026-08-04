import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/layout/profit_period_filter.dart';
import '../controllers/commissions_controller.dart';

class ShipmentProfitsHeader extends StatelessWidget {
  const ShipmentProfitsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommissionsController>(
      id: CommissionsController.listId,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي معاملات شركات الشحن',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_formatMoney(controller.totalShipmentWallet)} د.ع',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _HeaderMeta(
                        label: 'كل المعاملات',
                        value:
                            '${controller.filteredShipmentWallet.length}',
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _HeaderMeta(
                        label: 'مكتمل (إجمالي)',
                        value:
                            '${controller.doneShipmentWalletEntries.length}',
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _HeaderMeta(
                        label: 'قيد الانتظار',
                        value:
                            '${controller.pendingShipmentWalletEntries.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ProfitPeriodFilter(
              selected: controller.shipmentProfitPeriod,
              onSelected: controller.setShipmentProfitPeriod,
              activeColor: AppColors.info,
            ),
          ],
        );
      },
    );
  }

  static String _formatMoney(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.surface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
