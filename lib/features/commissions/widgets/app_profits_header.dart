import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/layout/profit_period_filter.dart';
import '../controllers/commissions_controller.dart';

class AppProfitsHeader extends StatelessWidget {
  const AppProfitsHeader({super.key});

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
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي أرباح التطبيق',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_formatMoney(controller.totalAppProfit)} د.ع',
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
                        value: '${controller.profitTransactions.length}',
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _HeaderMeta(
                        label: 'مكتمل (done)',
                        value: '${controller.doneProfitTransactions.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ProfitPeriodFilter(
              selected: controller.profitPeriod,
              onSelected: controller.setProfitPeriod,
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

class AppCommissionPercentCard extends StatelessWidget {
  const AppCommissionPercentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommissionsController>(
      id: CommissionsController.settingsId,
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
                      Icons.percent,
                      color: AppColors.primary,
                      size: AppIconSize.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('نسبة عمولة التطبيق', style: AppTextStyles.h6),
                        Text(
                          'من مجموعة app_commission',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${controller.appCommissionSettings?.value ?? '—'}%',
                    style: AppTextStyles.h5.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.appPercentController,
                      enabled: !controller.isSavingAppPercent,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                        ),
                      ],
                      style: AppTextStyles.body1,
                      decoration: InputDecoration(
                        labelText: 'النسبة %',
                        hintText: 'مثال: 5',
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'حفظ',
                    isLoading: controller.isSavingAppPercent,
                    onPressed: controller.saveAppCommissionPercent,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
