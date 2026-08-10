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
import 'shipment_request_money_card.dart';
import 'shipment_wallet_card.dart';
import 'vendor_money_request_card.dart';
import 'vendor_wallet_card.dart';

class CommissionsDetailPanel extends StatelessWidget {
  const CommissionsDetailPanel({
    super.key,
    this.showBack = false,
    this.embedded = false,
  });

  final bool showBack;
  /// When true, renders content only (page handles chrome/back).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommissionsController>(
      id: CommissionsController.detailId,
      builder: (controller) {
        if (controller.selectedProfitTrans == null &&
            controller.selectedVendorWallet == null &&
            controller.selectedShipmentWallet == null &&
            controller.selectedShipmentMoneyRequest == null &&
            controller.selectedVendorMoneyRequest == null) {
          return const AppEmptyState(
            title: 'اختر عنصرًا',
            subtitle:
                'حدد ربح تطبيق أو تاجر أو شركة شحن أو طلب سحب لعرض التفاصيل',
            icon: Icons.hub_outlined,
          );
        }

        final content = ListView(
          padding: embedded
              ? EdgeInsets.zero
              : const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            if (controller.selectedProfitTrans != null)
              _ProfitTransDetail(controller: controller)
            else if (controller.selectedVendorWallet != null)
              _VendorWalletDetail(controller: controller)
            else if (controller.selectedShipmentWallet != null)
              _ShipmentWalletDetail(controller: controller)
            else if (controller.selectedShipmentMoneyRequest != null)
              _ShipmentMoneyRequestDetail(controller: controller)
            else
              _VendorMoneyRequestDetail(controller: controller),
          ],
        );

        if (embedded) return content;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    controller.clearSelection();
                    if (Get.key.currentState?.canPop() == true) {
                      Get.back();
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, size: AppIconSize.md),
                  label: const Text('رجوع للقائمة'),
                ),
              ),
            Expanded(child: content),
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
                subtitle: 'فتح تفاصيل الطلب المرتبط',
                icon: Icons.assignment_outlined,
                color: AppColors.info,
                actionLabel: 'فتح الطلب',
                onAction: () => DeepLinkNavigation.openRequest(
                  requestId: t.requestId,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _ProfitLinkedDetailsSection(controller: controller),
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
                subtitle: 'فتح تفاصيل الطلب المرتبط',
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
                subtitle: 'فتح صفحة التاجر',
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
              if (e.paymentType.trim().isNotEmpty)
                _CalcRow(label: 'طريقة الدفع', value: e.paymentType),
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
                subtitle: 'فتح تفاصيل الطلب المرتبط',
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
                subtitle: 'فتح صفحة التاجر',
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
              if (e.paymentType.trim().isNotEmpty)
                _CalcRow(label: 'طريقة الدفع', value: e.paymentType),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShipmentMoneyRequestDetail extends StatelessWidget {
  const _ShipmentMoneyRequestDetail({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final r = controller.selectedShipmentMoneyRequest!;
    final linked = controller.shipmentWallet
        .where((e) => r.transIds.contains(e.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('طلب سحب أموال الشحن', style: AppTextStyles.h4),
            ),
            StatusBadge(status: r.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'shipment_request_money → trans_ids → shipments_wallet (done → sent)',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        ShipmentRequestMoneyCard(
          request: r,
          isActing: controller.actingShipmentMoneyRequestId == r.id,
          onApprove: r.isPending
              ? () => controller.confirmApproveShipmentMoneyRequest(r)
              : null,
          onReject: r.isPending
              ? () => controller.confirmRejectShipmentMoneyRequest(r)
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
              Text('بيانات الطلب', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              _CalcRow(
                label: 'المبلغ',
                value: '${r.amount} د.ع',
                emphasize: true,
              ),
              _CalcRow(
                label: 'طريقة الدفع',
                value: r.paymentMethod.isEmpty ? '—' : r.paymentMethod,
              ),
              _CalcRow(
                label: 'الهاتف',
                value: r.phone.isEmpty ? '—' : r.phone,
              ),
              _CalcRow(
                label: 'الإيميل',
                value: r.userEmail.isEmpty ? '—' : r.userEmail,
              ),
              _CalcRow(
                label: 'التاريخ',
                value: DateFormatUtils.format(r.createdAt),
              ),
              if (r.howToGetMoney.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('طريقة الاستلام', style: AppTextStyles.caption),
                Text(r.howToGetMoney, style: AppTextStyles.body2),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'المعاملات المرتبطة (${r.transIds.length})',
          style: AppTextStyles.h5,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'عند الإرسال تتحول حالة done إلى sent في shipments_wallet',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        if (linked.isEmpty)
          const AppEmptyState(
            title: 'لا توجد معاملات محملة',
            subtitle: 'تفاصيل المعاملات ستظهر هنا عند توفرها في القائمة',
            icon: Icons.link_off,
          )
        else
          ...linked.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ShipmentWalletCard(
                entry: entry,
                onTap: () => controller.selectShipmentWallet(entry),
              ),
            ),
          ),
      ],
    );
  }
}

class _VendorMoneyRequestDetail extends StatelessWidget {
  const _VendorMoneyRequestDetail({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final r = controller.selectedVendorMoneyRequest!;
    final linked = controller.vendorWallet
        .where((e) => r.vendorsWalletIds.contains(e.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('طلب سحب أموال التاجر', style: AppTextStyles.h4),
            ),
            StatusBadge(status: r.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'عند الإرسال تتحول حالة الطلب والمعاملات المرتبطة إلى sent',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        VendorMoneyRequestCard(
          request: r,
          isActing: controller.actingVendorMoneyRequestId == r.id,
          onApprove: r.isPending
              ? () => controller.confirmApproveVendorMoneyRequest(r)
              : null,
          onReject: r.isPending
              ? () => controller.confirmRejectVendorMoneyRequest(r)
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
              Text('بيانات الطلب', style: AppTextStyles.h6),
              const SizedBox(height: AppSpacing.md),
              _CalcRow(
                label: 'المحل',
                value: r.shopName.isEmpty ? '—' : r.shopName,
              ),
              _CalcRow(
                label: 'المبلغ',
                value: '${r.amount} د.ع',
                emphasize: true,
              ),
              _CalcRow(
                label: 'طريقة الدفع',
                value: r.paymentMethod.isEmpty ? '—' : r.paymentMethod,
              ),
              _CalcRow(
                label: 'الهاتف',
                value: r.phone.isEmpty ? '—' : r.phone,
              ),
              _CalcRow(
                label: 'التاريخ',
                value: DateFormatUtils.format(r.createdAt),
              ),
              if (r.workerId.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'فتح صفحة التاجر',
                  icon: Icons.storefront_outlined,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => DeepLinkNavigation.openVendor(
                    vendorId: r.workerId,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'المعاملات المرتبطة (${r.vendorsWalletIds.length})',
          style: AppTextStyles.h5,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'عند الإرسال تتحول حالة هذه المعاملات في vendors_wallet إلى sent',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        if (linked.isEmpty)
          const AppEmptyState(
            title: 'لا توجد معاملات محملة',
            subtitle: 'تفاصيل المعاملات ستظهر هنا عند توفرها في القائمة',
            icon: Icons.link_off,
          )
        else
          ...linked.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: VendorWalletCard(
                entry: entry,
                onTap: () => controller.selectVendorWallet(entry),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfitLinkedDetailsSection extends StatelessWidget {
  const _ProfitLinkedDetailsSection({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingLinkedDetails) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: AppLoader(message: 'جاري تحميل التفاصيل المرتبطة...'),
      );
    }

    final details = controller.profitLinkedDetails;
    if (details == null || !details.hasAny) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('التفاصيل المرتبطة', style: AppTextStyles.h5),
        const SizedBox(height: AppSpacing.md),
        if (details.order != null)
          _LinkedDetailCard(
            title: 'الطلبية',
            icon: Icons.shopping_bag_outlined,
            color: AppColors.primary,
            rows: [
              _CalcRow(
                label: 'المنتج',
                value: details.order!.partName.isEmpty
                    ? '—'
                    : details.order!.partName,
              ),
              _CalcRow(
                label: 'العميل',
                value: details.order!.customerName.isEmpty
                    ? '—'
                    : details.order!.customerName,
              ),
              _CalcRow(
                label: 'المحل',
                value: details.order!.shopName.isEmpty
                    ? '—'
                    : details.order!.shopName,
              ),
              _CalcRow(
                label: 'السعر',
                value: '${details.order!.price} د.ع',
                emphasize: true,
              ),
              if (details.order!.condition.trim().isNotEmpty)
                _CalcRow(label: 'الحالة', value: details.order!.condition),
            ],
          ),
        if (details.payment != null)
          _LinkedDetailCard(
            title: 'معاملة الدفع',
            icon: Icons.payments_outlined,
            color: AppColors.success,
            rows: [
              _CalcRow(
                label: 'المبلغ',
                value:
                    '${details.payment!.amount} ${details.payment!.currency}',
                emphasize: true,
              ),
              _CalcRow(
                label: 'طريقة الدفع',
                value: details.payment!.method.isEmpty
                    ? '—'
                    : details.payment!.method,
              ),
              _CalcRow(
                label: 'الحالة',
                value: details.payment!.status.isEmpty
                    ? '—'
                    : details.payment!.status,
              ),
              _CalcRow(
                label: 'التاريخ',
                value: DateFormatUtils.format(details.payment!.createdAt),
              ),
            ],
          ),
        if (details.shipmentOffer != null)
          _LinkedDetailCard(
            title: 'عرض الشحن',
            icon: Icons.local_shipping_outlined,
            color: AppColors.info,
            rows: [
              _CalcRow(
                label: 'سعر الشحن',
                value: '${details.shipmentOffer!.shippingPrice} د.ع',
                emphasize: true,
              ),
              _CalcRow(
                label: 'الحالة',
                value: details.shipmentOffer!.status.isEmpty
                    ? '—'
                    : details.shipmentOffer!.status,
              ),
              _CalcRow(
                label: 'البريد',
                value: details.shipmentOffer!.email.isEmpty
                    ? '—'
                    : details.shipmentOffer!.email,
              ),
              if (details.shipmentOffer!.notes.trim().isNotEmpty)
                _CalcRow(
                  label: 'ملاحظات',
                  value: details.shipmentOffer!.notes,
                ),
            ],
          ),
        if (details.shipmentCompany != null)
          _LinkedDetailCard(
            title: 'شركة الشحن',
            icon: Icons.store_mall_directory_outlined,
            color: AppColors.secondary,
            rows: [
              _CalcRow(
                label: 'الاسم',
                value: details.shipmentCompany!.name.isEmpty
                    ? '—'
                    : details.shipmentCompany!.name,
              ),
              _CalcRow(
                label: 'البريد',
                value: details.shipmentCompany!.email.isEmpty
                    ? '—'
                    : details.shipmentCompany!.email,
              ),
              _CalcRow(
                label: 'التقييم',
                value: '${details.shipmentCompany!.rate}',
              ),
              if (details.shipmentCompany!.vehicleSizeType.trim().isNotEmpty)
                _CalcRow(
                  label: 'حجم المركبة',
                  value: details.shipmentCompany!.vehicleSizeType,
                ),
            ],
          ),
      ],
    );
  }
}

class _LinkedDetailCard extends StatelessWidget {
  const _LinkedDetailCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: color, size: AppIconSize.md),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTextStyles.h6),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...rows,
          ],
        ),
      ),
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
