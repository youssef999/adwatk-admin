import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../controllers/shipping_stores_controller.dart';

/// Edits `app_commission_shipemnt_values` — amount deducted from the courier
/// per delivered order. 0 disables the deduction.
class ShipmentAppCommissionCard extends StatelessWidget {
  const ShipmentAppCommissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShippingStoresController>(
      id: ShippingStoresController.appCommissionId,
      builder: (controller) {
        final saving = controller.isSavingAppCommission;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.percent_rounded,
                      color: AppColors.warning,
                      size: AppIconSize.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('عمولة التطبيق من المندوب', style: AppTextStyles.h6),
                        Text(
                          'تُخصم من رصيد المندوب على كل طلب ناجح — 0 = بدون خصم',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final sideBySide = constraints.maxWidth >= 520;
                  final inField = _CommissionField(
                    label: 'داخل المدينة',
                    controller: controller.inCityCommissionController,
                    enabled: !saving,
                  );
                  final outField = _CommissionField(
                    label: 'خارج المدينة',
                    controller: controller.outCityCommissionController,
                    enabled: !saving,
                  );

                  if (!sideBySide) {
                    return Column(
                      children: [
                        inField,
                        const SizedBox(height: AppSpacing.md),
                        outField,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: inField),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: outField),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppButton(
                  label: 'حفظ',
                  icon: Icons.save_outlined,
                  isLoading: saving,
                  onPressed: saving ? null : controller.saveAppCommission,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommissionField extends StatelessWidget {
  const _CommissionField({
    required this.label,
    required this.controller,
    required this.enabled,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppTextStyles.body1,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'مثال: 250',
        filled: true,
        fillColor: AppColors.background,
        suffixText: 'د.ع',
      ),
    );
  }
}
