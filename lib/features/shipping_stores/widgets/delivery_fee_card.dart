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

class DeliveryFeeCard extends StatelessWidget {
  const DeliveryFeeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShippingStoresController>(
      id: ShippingStoresController.deliveryFeeId,
      builder: (controller) {
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
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.primary,
                      size: AppIconSize.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رسوم التوصيل', style: AppTextStyles.h6),
                        Text(
                          'delivery_fee',
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
                  final inField = _FeeField(
                    label: 'داخل المدينة (in_city)',
                    controller: controller.inCityFeeController,
                    enabled: !controller.isSavingDeliveryFee,
                  );
                  final outField = _FeeField(
                    label: 'خارج المدينة (out_city)',
                    controller: controller.outCityFeeController,
                    enabled: !controller.isSavingDeliveryFee,
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
                  isLoading: controller.isSavingDeliveryFee,
                  onPressed: controller.isSavingDeliveryFee
                      ? null
                      : controller.saveDeliveryFee,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeeField extends StatelessWidget {
  const _FeeField({
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      style: AppTextStyles.body1,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'مثال: 10000',
        filled: true,
        fillColor: AppColors.background,
        suffixText: 'د.ع',
      ),
    );
  }
}
