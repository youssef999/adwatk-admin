import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/deep_link_navigation.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../requests/widgets/status_badge.dart';
import '../controllers/commissions_controller.dart';
import 'provider_commission_card.dart';

class CommissionsDetailPanel extends StatelessWidget {
  const CommissionsDetailPanel({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommissionsController>(
      id: CommissionsController.detailId,
      builder: (controller) {
        if (controller.selectedCommission == null &&
            controller.selectedIncentive == null) {
          return const AppEmptyState(
            title: 'اختر عنصرًا',
            subtitle:
                'حدد عمولة بائع أو طلب حافز لعرض الارتباط مع الطلب والعرض والبائع',
            icon: Icons.hub_outlined,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: controller.clearSelection,
                  icon: const Icon(Icons.arrow_forward, size: AppIconSize.md),
                  label: const Text('رجوع للقائمة'),
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  if (controller.selectedCommission != null)
                    _CommissionDetail(controller: controller)
                  else
                    _IncentiveDetail(controller: controller),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommissionDetail extends StatelessWidget {
  const _CommissionDetail({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller.selectedCommission!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('تفاصيل عمولة البائع', style: AppTextStyles.h4),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'provider_commission ↔ request + offer + vendor',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProviderCommissionCard(commission: c),
        const SizedBox(height: AppSpacing.lg),
        _RelationMap(
          items: [
            if (c.requestId.trim().isNotEmpty)
              _RelationItem(
                title: 'الطلب',
                subtitle: c.requestId,
                icon: Icons.assignment_outlined,
                color: AppColors.info,
                actionLabel: 'فتح الطلب',
                onAction: () => DeepLinkNavigation.openRequest(
                  requestId: c.requestId,
                  offerId: c.offerId,
                ),
              ),
            if (c.offerId.trim().isNotEmpty && c.requestId.trim().isNotEmpty)
              _RelationItem(
                title: 'العرض',
                subtitle: c.offerId,
                icon: Icons.local_offer_outlined,
                color: AppColors.primary,
                actionLabel: 'فتح العرض',
                onAction: () => DeepLinkNavigation.openRequest(
                  requestId: c.requestId,
                  offerId: c.offerId,
                ),
              ),
            if (c.workerId.trim().isNotEmpty)
              _RelationItem(
                title: 'البائع',
                subtitle: c.shopName.trim().isEmpty
                    ? c.workerId
                    : '${c.shopName}\n${c.workerId}',
                icon: Icons.storefront_outlined,
                color: AppColors.secondary,
                actionLabel: 'فتح البائع',
                onAction: () => DeepLinkNavigation.openVendor(
                  vendorId: c.workerId,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('حساب العمولة', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              _CalcRow(label: 'سعر العرض', value: '${c.price} د.ع'),
              _CalcRow(
                label: 'نسبة التطبيق',
                value: '${c.commissionPercent}%',
              ),
              _CalcRow(
                label: 'عمولة التطبيق',
                value: '${c.appCommission} د.ع',
              ),
              _CalcRow(
                label: 'صافي البائع',
                value: '${c.providerCommission} د.ع',
                emphasize: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'التاريخ: ${DateFormatUtils.format(c.createdAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncentiveDetail extends StatelessWidget {
  const _IncentiveDetail({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final incentive = controller.selectedIncentive!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('تفاصيل طلب الحافز', style: AppTextStyles.h4),
            ),
            StatusBadge(status: incentive.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'incentive_requests → commissionDocIds → provider_commission → request/offer',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(incentive.shopName, style: AppTextStyles.h5),
              const SizedBox(height: AppSpacing.md),
              _CalcRow(
                label: 'قيمة الحافز',
                value: '${incentive.incentiveAmount} د.ع',
                emphasize: true,
              ),
              _CalcRow(
                label: 'نسبة الحافز',
                value: '${incentive.incentivePercent}%',
              ),
              _CalcRow(
                label: 'عدد المبيعات',
                value: '${incentive.salesCount}',
              ),
              _CalcRow(
                label: 'إجمالي عمولة التطبيق',
                value: '${incentive.totalAppCommission} د.ع',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (incentive.workerId.trim().isNotEmpty) ...[
                Text(
                  'workerId: ${incentive.workerId}',
                  style: AppTextStyles.caption,
                ),
                Text(
                  'التاريخ: ${DateFormatUtils.format(incentive.createdAt)}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'فتح هذا البائع',
                  icon: Icons.storefront_outlined,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => DeepLinkNavigation.openVendor(
                    vendorId: incentive.workerId,
                  ),
                ),
              ] else ...[
                Text(
                  'التاريخ: ${DateFormatUtils.format(incentive.createdAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'العمولات المرتبطة (${controller.incentiveLinkedCommissions.length})',
          style: AppTextStyles.h5,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'كل عنصر يربط طلبًا وعرضًا وبائعًا عبر provider_commission',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        if (controller.isLoadingDetail)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppLoader(message: 'جاري تحميل العمولات المرتبطة...'),
          )
        else if (controller.incentiveLinkedCommissions.isEmpty)
          const AppEmptyState(
            title: 'لا توجد عمولات مرتبطة',
            subtitle: 'commissionDocIds فارغة أو غير موجودة',
            icon: Icons.link_off,
          )
        else
          ...controller.incentiveLinkedCommissions.map(
            (commission) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ProviderCommissionCard(
                commission: commission,
                onTap: () => controller.selectCommission(commission),
              ),
            ),
          ),
      ],
    );
  }
}

class _RelationMap extends StatelessWidget {
  const _RelationMap({required this.items});

  final List<_RelationItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: item.color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.color),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: AppTextStyles.h6),
                          Text(item.subtitle, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: item.onAction,
                      child: Text(item.actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RelationItem {
  const _RelationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String actionLabel;
  final VoidCallback onAction;
}

class _CalcRow extends StatelessWidget {
  const _CalcRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body2)),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
