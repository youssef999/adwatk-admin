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
import 'app_profit_trans_card.dart';
import 'provider_commission_card.dart';
import 'shipment_wallet_card.dart';
import 'vendor_wallet_card.dart';

class CommissionsDetailPanel extends StatelessWidget {
  const CommissionsDetailPanel({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommissionsController>(
      id: CommissionsController.detailId,
      builder: (controller) {
        if (controller.selectedProfitTrans == null &&
            controller.selectedVendorWallet == null &&
            controller.selectedShipmentWallet == null &&
            controller.selectedIncentive == null) {
          return const AppEmptyState(
            title: 'اختر عنصرًا',
            subtitle:
                'حدد ربح تطبيق أو تاجر أو شركة شحن أو طلب حافز لعرض التفاصيل',
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
                  if (controller.selectedProfitTrans != null)
                    _ProfitTransDetail(controller: controller)
                  else if (controller.selectedVendorWallet != null)
                    _VendorWalletDetail(controller: controller)
                  else if (controller.selectedShipmentWallet != null)
                    _ShipmentWalletDetail(controller: controller)
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

class _ProfitTransDetail extends StatelessWidget {
  const _ProfitTransDetail({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final t = controller.selectedProfitTrans!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('تفاصيل ربح التطبيق', style: AppTextStyles.h4),
            ),
            StatusBadge(status: t.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'app_profits_trans — تُعرض كل المعاملات، ويُحتسب الإجمالي فقط عند status = done',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppProfitTransCard(transaction: t),
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
              Text('بيانات المعاملة', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              _CalcRow(
                label: 'المبلغ (amount)',
                value: '${t.amount} د.ع',
                emphasize: true,
              ),
              _CalcRow(label: 'نوع الدفع', value: t.paymentType.isEmpty ? '—' : t.paymentType),
              _CalcRow(label: 'الحالة', value: t.status.isEmpty ? '—' : t.status),
              _CalcRow(
                label: 'اكتمال',
                value: DateFormatUtils.format(t.completedAt),
              ),
              _CalcRow(
                label: 'إنشاء',
                value: DateFormatUtils.format(t.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _RelationMap(
          items: [
            if (t.requestId.trim().isNotEmpty)
              _RelationItem(
                title: 'الطلب',
                subtitle: t.requestId,
                icon: Icons.assignment_outlined,
                color: AppColors.info,
                actionLabel: 'فتح الطلب',
                onAction: () => DeepLinkNavigation.openRequest(
                  requestId: t.requestId,
                ),
              ),
          ],
        ),
        if (t.orderId.trim().isNotEmpty ||
            t.paymentTransactionId.trim().isNotEmpty ||
            t.shipmentOrderId.trim().isNotEmpty ||
            t.shipmentId.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
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
                Text('المعرفات المرتبطة', style: AppTextStyles.h6),
                const SizedBox(height: AppSpacing.md),
                if (t.orderId.trim().isNotEmpty)
                  _CalcRow(label: 'order_id', value: t.orderId),
                if (t.paymentTransactionId.trim().isNotEmpty)
                  _CalcRow(
                    label: 'payment_transaction_id',
                    value: t.paymentTransactionId,
                  ),
                if (t.shipmentOrderId.trim().isNotEmpty)
                  _CalcRow(
                    label: 'shipment_order_id',
                    value: t.shipmentOrderId,
                  ),
                if (t.shipmentId.trim().isNotEmpty)
                  _CalcRow(label: 'shipment_id', value: t.shipmentId),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _VendorWalletDetail extends StatelessWidget {
  const _VendorWalletDetail({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final e = controller.selectedVendorWallet!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('تفاصيل أرباح التاجر', style: AppTextStyles.h4),
            ),
            StatusBadge(status: e.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'vendors_wallet — تُعرض كل الحالات، ويُحتسب الإجمالي فقط عند status = done',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        VendorWalletCard(
          entry: e,
          isMarkingSent: controller.markingVendorSentId == e.id,
          onMarkSent: e.canMarkAsSent
              ? () => controller.confirmMarkVendorWalletSent(e)
              : null,
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
              Text('الحساب', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              _CalcRow(
                label: 'ربح التاجر (amount)',
                value: '${e.amount} ${e.currency.isEmpty ? 'د.ع' : e.currency}',
                emphasize: true,
              ),
              _CalcRow(label: 'سعر الطلب', value: '${e.orderPrice} د.ع'),
              _CalcRow(label: 'سعر الشحن', value: '${e.shippingPrice} د.ع'),
              _CalcRow(
                label: 'عمولة التطبيق',
                value: '${e.appCommission} د.ع',
              ),
              _CalcRow(
                label: 'نسبة العمولة',
                value: '${e.commissionPercent}%',
              ),
              _CalcRow(
                label: 'نوع الدفع',
                value: e.paymentType.isEmpty ? '—' : e.paymentType,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'اكتمال: ${DateFormatUtils.format(e.completedAt)}',
                style: AppTextStyles.caption,
              ),
              Text(
                'إنشاء: ${DateFormatUtils.format(e.createdAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _RelationMap(
          items: [
            if (e.requestId.trim().isNotEmpty)
              _RelationItem(
                title: 'الطلب',
                subtitle: e.requestId,
                icon: Icons.assignment_outlined,
                color: AppColors.info,
                actionLabel: 'فتح الطلب',
                onAction: () => DeepLinkNavigation.openRequest(
                  requestId: e.requestId,
                ),
              ),
            if (e.vendorId.trim().isNotEmpty)
              _RelationItem(
                title: 'التاجر',
                subtitle: e.vendorId,
                icon: Icons.storefront_outlined,
                color: AppColors.secondary,
                actionLabel: 'فتح التاجر',
                onAction: () => DeepLinkNavigation.openVendor(
                  vendorId: e.vendorId,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
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
              Text('التفاصيل المرتبطة', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              if (e.productName.trim().isNotEmpty)
                _CalcRow(label: 'المنتج', value: e.productName),
              if (e.customerName.trim().isNotEmpty)
                _CalcRow(label: 'العميل', value: e.customerName),
              if (e.shipmentCompanyName.trim().isNotEmpty)
                _CalcRow(
                  label: 'شركة الشحن',
                  value: e.shipmentCompanyName,
                ),
              if (e.orderId.trim().isNotEmpty)
                _CalcRow(label: 'order_id', value: e.orderId),
              if (e.paymentTransactionId.trim().isNotEmpty)
                _CalcRow(
                  label: 'payment_transaction_id',
                  value: e.paymentTransactionId,
                ),
              if (e.shipmentOfferId.trim().isNotEmpty)
                _CalcRow(
                  label: 'shipment_offer_id',
                  value: e.shipmentOfferId,
                ),
              if (e.shipmentCompanyId.trim().isNotEmpty)
                _CalcRow(
                  label: 'shipment_company_id',
                  value: e.shipmentCompanyId,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShipmentWalletDetail extends StatelessWidget {
  const _ShipmentWalletDetail({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final e = controller.selectedShipmentWallet!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('تفاصيل معاملة الشحن', style: AppTextStyles.h4),
            ),
            StatusBadge(status: e.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          e.isPending
              ? 'قيد الانتظار — غير محسوبة في الإجمالي'
              : 'shipments_wallet — تُعرض كل الحالات، ويُحتسب الإجمالي فقط عند status = done',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        ShipmentWalletCard(
          entry: e,
          isMarkingSent: controller.markingShipmentSentId == e.id,
          onMarkSent: e.isDone
              ? () => controller.confirmMarkShipmentWalletSent(e)
              : null,
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
              Text('بيانات المعاملة', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              _CalcRow(
                label: 'المبلغ (amount)',
                value: '${e.amount} ${e.currency.isEmpty ? 'د.ع' : e.currency}',
                emphasize: true,
              ),
              _CalcRow(
                label: 'نوع الدفع',
                value: e.paymentType.isEmpty ? '—' : e.paymentType,
              ),
              _CalcRow(
                label: 'الحالة',
                value: e.isPending
                    ? 'pending — قيد الانتظار'
                    : (e.status.isEmpty ? '—' : e.status),
              ),
              _CalcRow(
                label: 'اكتمال',
                value: DateFormatUtils.format(e.completedAt),
              ),
              _CalcRow(
                label: 'إنشاء',
                value: DateFormatUtils.format(e.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _RelationMap(
          items: [
            if (e.requestId.trim().isNotEmpty)
              _RelationItem(
                title: 'الطلب',
                subtitle: e.requestId,
                icon: Icons.assignment_outlined,
                color: AppColors.info,
                actionLabel: 'فتح الطلب',
                onAction: () => DeepLinkNavigation.openRequest(
                  requestId: e.requestId,
                ),
              ),
            if (e.vendorId.trim().isNotEmpty)
              _RelationItem(
                title: 'التاجر',
                subtitle: e.vendorId,
                icon: Icons.storefront_outlined,
                color: AppColors.secondary,
                actionLabel: 'فتح التاجر',
                onAction: () => DeepLinkNavigation.openVendor(
                  vendorId: e.vendorId,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
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
              Text('التفاصيل المرتبطة', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              if (e.shipmentCompanyName.trim().isNotEmpty)
                _CalcRow(
                  label: 'شركة الشحن',
                  value: e.shipmentCompanyName,
                ),
              if (e.productName.trim().isNotEmpty)
                _CalcRow(label: 'المنتج', value: e.productName),
              if (e.customerName.trim().isNotEmpty)
                _CalcRow(label: 'العميل', value: e.customerName),
              if (e.orderId.trim().isNotEmpty)
                _CalcRow(label: 'order_id', value: e.orderId),
              if (e.paymentTransactionId.trim().isNotEmpty)
                _CalcRow(
                  label: 'payment_transaction_id',
                  value: e.paymentTransactionId,
                ),
              if (e.shipmentOfferId.trim().isNotEmpty)
                _CalcRow(
                  label: 'shipment_offer_id',
                  value: e.shipmentOfferId,
                ),
              if (e.shipmentCompanyId.trim().isNotEmpty)
                _CalcRow(
                  label: 'shipment_company_id',
                  value: e.shipmentCompanyId,
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
              child: ProviderCommissionCard(commission: commission),
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
