import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../controllers/users_controller.dart';
import '../models/customer_model.dart';
import 'customer_form_dialog.dart';
import 'customer_note_dialog.dart';
import 'user_wallet_dialog.dart';

class CustomerListItem extends StatelessWidget {
  const CustomerListItem({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final walletAmount = controller.walletAmountFor(customer);
    final minAlert = controller.minWalletAlertFor(customer);
    final latestNote = controller.latestNoteFor(customer);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              customer.fullName.isNotEmpty
                  ? customer.fullName.characters.first
                  : '?',
              style: AppTextStyles.h5.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.fullName, style: AppTextStyles.h6),
                const SizedBox(height: AppSpacing.xs),
                Text(customer.email, style: AppTextStyles.body2),
                const SizedBox(height: AppSpacing.xs),
                Text(customer.phoneNumber, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  controller.isPhoneLinked(customer)
                      ? 'الهاتف مربوط لتسجيل الدخول'
                      : 'الهاتف غير مربوط',
                  style: AppTextStyles.caption.copyWith(
                    color: controller.isPhoneLinked(customer)
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'المحفظة: ${_formatAmount(walletAmount)}',
                  style: AppTextStyles.caption.copyWith(
                    color: walletAmount < 0
                        ? AppColors.error
                        : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  minAlert == null
                      ? 'الحد الأقصى في السالب: —'
                      : minAlert == 0
                          ? 'الرصيد السالب: مقيد (حد = 0)'
                          : 'الحد الأقصى في السالب: ${_formatAmount(minAlert)}',
                  style: AppTextStyles.caption.copyWith(
                    color: minAlert == 0
                        ? AppColors.error
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (latestNote != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'آخر ملاحظة',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
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
                                latestNote.type,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          latestNote.title.isEmpty ? '—' : latestNote.title,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          latestNote.details.isEmpty ? '—' : latestNote.details,
                          style: AppTextStyles.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          DateFormatUtils.format(latestNote.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!controller.isPhoneLinked(customer))
            IconButton(
              tooltip: 'ربط الهاتف',
              onPressed: () => controller.linkCustomerPhone(customer),
              icon: const Icon(Icons.link, size: AppIconSize.md),
              color: AppColors.primary,
            ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'عميل',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'إرسال إشعار',
            onPressed: () => controller.openSendNotification(customer),
            icon: const Icon(
              Icons.notifications_active_outlined,
              size: AppIconSize.md,
            ),
            color: AppColors.primary,
          ),
          IconButton(
            tooltip: 'إضافة ملاحظة',
            onPressed: () => _openNote(controller),
            icon: const Icon(Icons.note_add_outlined, size: AppIconSize.md),
            color: AppColors.secondary,
          ),
          IconButton(
            tooltip: 'المحفظة والحد الأقصى',
            onPressed: () => _openWallet(controller),
            icon: const Icon(
              Icons.account_balance_wallet_outlined,
              size: AppIconSize.md,
            ),
            color: AppColors.success,
          ),
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
    );
  }

  String _formatAmount(num value) {
    final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$text د.ع';
  }

  Future<void> _openWallet(UsersController controller) async {
    controller.prepareWalletAdjust(customer);
    await Get.dialog<bool>(
      const UserWalletDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _openNote(UsersController controller) async {
    controller.prepareAddCustomerNote(customer);
    await Get.dialog<bool>(
      const CustomerNoteDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _openEdit(UsersController controller) async {
    await controller.prepareEdit(customer);
    await Get.dialog<bool>(
      const CustomerFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete(UsersController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف المستخدم', style: AppTextStyles.h5),
        content: Text(
          'هل تريد حذف "${customer.fullName}"؟',
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
      await controller.deleteCustomer(customer);
    }
  }
}
