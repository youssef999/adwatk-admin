import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/commissions_controller.dart';
import '../widgets/app_profit_trans_card.dart';
import '../widgets/app_profits_header.dart';
import '../widgets/commissions_detail_panel.dart';
import '../widgets/incentive_request_card.dart';
import '../widgets/shipment_profits_header.dart';
import '../widgets/shipment_wallet_card.dart';
import '../widgets/vendor_profits_header.dart';
import '../widgets/vendor_wallet_card.dart';

class CommissionsPage extends StatelessWidget {
  const CommissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommissionsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.applyRouteArguments();
    });

    return AppScaffold(
      title: 'العمولات والأرباح',
      actions: [
        IconButton(
          tooltip: 'تحديث',
          onPressed: controller.loadAll,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = !Breakpoints.isMobile(constraints.maxWidth);

          return GetBuilder<CommissionsController>(
            id: CommissionsController.listId,
            builder: (controller) {
              if (controller.isLoading &&
                  controller.appProfitTrans.isEmpty &&
                  controller.vendorWallet.isEmpty &&
                  controller.shipmentWallet.isEmpty &&
                  controller.incentives.isEmpty &&
                  controller.appCommissionSettings == null) {
                return const AppLoader(message: 'جاري تحميل العمولات...');
              }

              if (controller.errorMessage != null &&
                  controller.appProfitTrans.isEmpty &&
                  controller.vendorWallet.isEmpty &&
                  controller.shipmentWallet.isEmpty &&
                  controller.incentives.isEmpty) {
                return AppErrorState(
                  message: controller.errorMessage!,
                  onRetry: controller.loadAll,
                );
              }

              if (!isWide &&
                  (controller.selectedProfitTrans != null ||
                      controller.selectedVendorWallet != null ||
                      controller.selectedShipmentWallet != null ||
                      controller.selectedIncentive != null)) {
                return const CommissionsDetailPanel(showBack: true);
              }

              final listPane = _ListPane(controller: controller);

              if (!isWide) return listPane;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: constraints.maxWidth < Breakpoints.tablet
                        ? 360
                        : 420,
                    child: listPane,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Expanded(child: CommissionsDetailPanel()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ListPane extends StatelessWidget {
  const _ListPane({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.workerFilter != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'فلتر تاجر: ${controller.workerFilter}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearWorkerFilter,
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ],
        const AppCommissionPercentCard(),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: switch (controller.activeTab) {
              CommissionsTab.profits =>
                'بحث بالطلب أو الطلبية أو الدفع أو المعاملة...',
              CommissionsTab.vendorWallet =>
                'بحث بالمنتج أو التاجر أو الطلب أو الحالة...',
              CommissionsTab.shipmentWallet =>
                'بحث بشركة الشحن أو المنتج أو الطلب أو الحالة...',
              CommissionsTab.incentives =>
                'بحث بالمحل أو الحالة أو workerId...',
            },
            hintStyle: AppTextStyles.body2,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _TabChip(
                    label: 'أرباح التطبيق',
                    count: controller.profitTransactions.length,
                    selected:
                        controller.activeTab == CommissionsTab.profits,
                    onTap: () =>
                        controller.setTab(CommissionsTab.profits),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TabChip(
                    label: 'أرباح التجار',
                    count: controller.filteredVendorWallet.length,
                    selected: controller.activeTab ==
                        CommissionsTab.vendorWallet,
                    onTap: () =>
                        controller.setTab(CommissionsTab.vendorWallet),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _TabChip(
                    label: 'شركات الشحن',
                    count: controller.filteredShipmentWallet.length,
                    selected: controller.activeTab ==
                        CommissionsTab.shipmentWallet,
                    onTap: () =>
                        controller.setTab(CommissionsTab.shipmentWallet),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TabChip(
                    label: 'طلبات الحوافز',
                    count: controller.filteredIncentives.length,
                    selected: controller.activeTab ==
                        CommissionsTab.incentives,
                    onTap: () =>
                        controller.setTab(CommissionsTab.incentives),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: switch (controller.activeTab) {
            CommissionsTab.profits => _ProfitsList(controller: controller),
            CommissionsTab.vendorWallet =>
              _VendorWalletList(controller: controller),
            CommissionsTab.shipmentWallet =>
              _ShipmentWalletList(controller: controller),
            CommissionsTab.incentives =>
              _IncentivesList(controller: controller),
          },
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: selected
                      ? AppColors.surface
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$count',
                style: AppTextStyles.h6.copyWith(
                  color:
                      selected ? AppColors.surface : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfitsList extends StatelessWidget {
  const _ProfitsList({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.profitTransactions;

    return ListView.separated(
      itemCount: items.isEmpty ? 2 : items.length + 1,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const AppProfitsHeader();
        }

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: AppEmptyState(
              title: 'لا أرباح في هذه الفترة',
              subtitle: 'جرّب فلتر يوم / أسبوع / شهر / سنة آخر',
              icon: Icons.trending_up,
            ),
          );
        }

        final item = items[index - 1];
        return AppProfitTransCard(
          transaction: item,
          selected: controller.selectedProfitTrans?.id == item.id,
          onTap: () => controller.selectProfitTrans(item),
        );
      },
    );
  }
}

class _VendorWalletList extends StatelessWidget {
  const _VendorWalletList({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredVendorWallet;

    return ListView.separated(
      itemCount: items.isEmpty ? 2 : items.length + 1,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const VendorProfitsHeader();
        }

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: AppEmptyState(
              title: 'لا أرباح تجار في هذه الفترة',
              subtitle: 'ستظهر معاملات vendors_wallet هنا',
              icon: Icons.account_balance_wallet_outlined,
            ),
          );
        }

        final item = items[index - 1];
        return VendorWalletCard(
          entry: item,
          selected: controller.selectedVendorWallet?.id == item.id,
          isMarkingSent: controller.markingVendorSentId == item.id,
          onTap: () => controller.selectVendorWallet(item),
          onMarkSent: item.canMarkAsSent
              ? () => controller.confirmMarkVendorWalletSent(item)
              : null,
        );
      },
    );
  }
}

class _ShipmentWalletList extends StatelessWidget {
  const _ShipmentWalletList({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredShipmentWallet;

    return ListView.separated(
      itemCount: items.isEmpty ? 2 : items.length + 1,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const ShipmentProfitsHeader();
        }

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: AppEmptyState(
              title: 'لا معاملات شحن في هذه الفترة',
              subtitle: 'ستظهر معاملات shipments_wallet هنا',
              icon: Icons.local_shipping_outlined,
            ),
          );
        }

        final item = items[index - 1];
        return ShipmentWalletCard(
          entry: item,
          selected: controller.selectedShipmentWallet?.id == item.id,
          isMarkingSent: controller.markingShipmentSentId == item.id,
          onTap: () => controller.selectShipmentWallet(item),
          onMarkSent: item.isDone
              ? () => controller.confirmMarkShipmentWalletSent(item)
              : null,
        );
      },
    );
  }
}

class _IncentivesList extends StatelessWidget {
  const _IncentivesList({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.incentives.isEmpty) {
      return const AppEmptyState(
        title: 'لا توجد طلبات حوافز',
        subtitle: 'طلبات incentive_requests ستظهر هنا',
        icon: Icons.card_giftcard_outlined,
      );
    }
    if (controller.filteredIncentives.isEmpty) {
      return const AppEmptyState(
        title: 'لا نتائج',
        subtitle: 'عدّل كلمات البحث',
        icon: Icons.search_off,
      );
    }

    return ListView.separated(
      itemCount: controller.filteredIncentives.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = controller.filteredIncentives[index];
        return IncentiveRequestCard(
          incentive: item,
          selected: controller.selectedIncentive?.id == item.id,
          onTap: () => controller.selectIncentive(item),
        );
      },
    );
  }
}
