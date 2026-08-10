import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/negative_balance_restrict_toggle.dart';
import '../controllers/users_controller.dart';

class UserWalletDialog extends StatelessWidget {
  const UserWalletDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UsersController>(
      id: UsersController.walletFormId,
      builder: (controller) {
        final customer = controller.walletCustomer;
        if (customer == null) return const SizedBox.shrink();

        final balance = controller.walletAmountFor(customer);
        final busy = controller.isAdjustingWallet;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'محفظة المستخدم والحد الأقصى',
                            style: AppTextStyles.h4,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              busy ? null : () => Get.back(result: false),
                          icon: const Icon(Icons.close, size: AppIconSize.md),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(customer.fullName, style: AppTextStyles.h6),
                    const SizedBox(height: AppSpacing.xs),
                    Text(customer.email, style: AppTextStyles.body2),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الرصيد الحالي',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _formatAmount(balance),
                            style: AppTextStyles.h3.copyWith(
                              color: balance < 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'المبلغ',
                      controller: controller.walletAmountController,
                      hint: 'مثال: 10000',
                      enabled: !busy,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (busy)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'خصم',
                            icon: Icons.remove,
                            variant: AppButtonVariant.danger,
                            isExpanded: true,
                            onPressed: busy
                                ? null
                                : () => controller.adjustWallet(isAdd: false),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: 'إضافة',
                            icon: Icons.add,
                            isExpanded: true,
                            onPressed: busy
                                ? null
                                : () => controller.adjustWallet(isAdd: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    NegativeBalanceRestrictToggle(
                      restricted:
                          controller.isWalletNegativeRestricted(customer),
                      enabled: !busy,
                      onChanged: controller.setWalletNegativeRestricted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!controller.isWalletNegativeRestricted(customer)) ...[
                      AppTextField(
                        label: 'الحد الأقصى في السالب (user_min_wallet_alert)',
                        controller: controller.walletMinAlertController,
                        hint: 'مثال: 50000',
                        enabled: !busy,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,]'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'حفظ الحد الأقصى',
                        icon: Icons.save_outlined,
                        isExpanded: true,
                        onPressed:
                            busy ? null : controller.saveWalletMinAlert,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatAmount(num value) {
    final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$text د.ع';
  }
}
