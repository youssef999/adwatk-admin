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
import '../widgets/shipment_profits_header.dart';
import '../widgets/shipment_request_money_card.dart';
import '../widgets/shipment_wallet_card.dart';
import '../widgets/vendor_money_request_card.dart';
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
      body: GetBuilder<CommissionsController>(
        id: CommissionsController.listId,
        builder: (controller) {
          if (controller.isLoading &&
              controller.appProfitTrans.isEmpty &&
              controller.vendorWallet.isEmpty &&
              controller.shipmentWallet.isEmpty &&
              controller.shipmentMoneyRequests.isEmpty &&
              controller.vendorMoneyRequests.isEmpty &&
              controller.appCommissionSettings == null) {
            return const AppLoader(message: 'جاري تحميل العمولات...');
          }

          if (controller.errorMessage != null &&
              controller.appProfitTrans.isEmpty &&
              controller.vendorWallet.isEmpty &&
              controller.shipmentWallet.isEmpty &&
              controller.shipmentMoneyRequests.isEmpty &&
              controller.vendorMoneyRequests.isEmpty) {
            return AppErrorState(
              message: controller.errorMessage!,
              onRetry: controller.loadAll,
            );
          }

          // Not const: must rebuild when GetBuilder(listId) updates (tabs/search).
          return _CommissionsFullWidthBody(controller: controller);
        },
      ),
    );
  }
}

class _CommissionsFullWidthBody extends StatelessWidget {
  const _CommissionsFullWidthBody({required this.controller});

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
              CommissionsTab.shipmentMoneyRequests =>
                'بحث بالإيميل أو الهاتف أو الحالة أو المعاملة...',
              CommissionsTab.vendorMoneyRequests =>
                'بحث بالمحل أو الهاتف أو طريقة الدفع أو الحالة...',
            },
            hintStyle: AppTextStyles.body2,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _TabChip(
                label: 'أرباح التطبيق',
                count: controller.profitTransactions.length,
                selected: controller.activeTab == CommissionsTab.profits,
                onTap: () => controller.setTab(CommissionsTab.profits),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TabChip(
                label: 'أرباح التجار',
                count: controller.filteredVendorWallet.length,
                selected: controller.activeTab == CommissionsTab.vendorWallet,
                onTap: () => controller.setTab(CommissionsTab.vendorWallet),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TabChip(
                label: 'شركات الشحن',
                count: controller.filteredShipmentWallet.length,
                selected:
                    controller.activeTab == CommissionsTab.shipmentWallet,
                onTap: () => controller.setTab(CommissionsTab.shipmentWallet),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TabChip(
                label: 'طلبات سحب الشحن',
                count: controller.filteredShipmentMoneyRequests.length,
                selected: controller.activeTab ==
                    CommissionsTab.shipmentMoneyRequests,
                onTap: () =>
                    controller.setTab(CommissionsTab.shipmentMoneyRequests),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TabChip(
                label: 'طلبات سحب التجار',
                count: controller.filteredVendorMoneyRequests.length,
                selected: controller.activeTab ==
                    CommissionsTab.vendorMoneyRequests,
                onTap: () =>
                    controller.setTab(CommissionsTab.vendorMoneyRequests),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: switch (controller.activeTab) {
            CommissionsTab.profits => _ProfitsList(controller: controller),
            CommissionsTab.vendorWallet =>
              _VendorWalletList(controller: controller),
            CommissionsTab.shipmentWallet =>
              _ShipmentWalletList(controller: controller),
            CommissionsTab.shipmentMoneyRequests =>
              _ShipmentMoneyRequestsList(controller: controller),
            CommissionsTab.vendorMoneyRequests =>
              _VendorMoneyRequestsList(controller: controller),
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
          constraints: const BoxConstraints(minWidth: 140),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

int _gridColumns(double width) {
  if (width >= Breakpoints.tablet) return 3;
  if (width >= Breakpoints.mobile) return 2;
  return 1;
}

class _ProfitsList extends StatelessWidget {
  const _ProfitsList({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.profitTransactions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _gridColumns(constraints.maxWidth);
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: AppProfitsHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  title: 'لا أرباح في هذه الفترة',
                  subtitle: 'جرّب فلتر يوم / أسبوع / شهر / سنة آخر',
                  icon: Icons.trending_up,
                ),
              )
            else
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 210,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return AppProfitTransCard(
                      transaction: item,
                      selected:
                          controller.selectedProfitTrans?.id == item.id,
                      onTap: () => controller.selectProfitTrans(item),
                    );
                  },
                  childCount: items.length,
                ),
              ),
          ],
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _gridColumns(constraints.maxWidth);
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: VendorProfitsHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  title: 'لا أرباح تجار في هذه الفترة',
                  subtitle: 'ستظهر معاملات vendors_wallet هنا',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              )
            else
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 300,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return VendorWalletCard(
                      entry: item,
                      selected:
                          controller.selectedVendorWallet?.id == item.id,
                      isMarkingSent:
                          controller.markingVendorSentId == item.id,
                      onTap: () => controller.selectVendorWallet(item),
                      onMarkSent: item.canMarkAsSent
                          ? () =>
                              controller.confirmMarkVendorWalletSent(item)
                          : null,
                    );
                  },
                  childCount: items.length,
                ),
              ),
          ],
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _gridColumns(constraints.maxWidth);
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: ShipmentProfitsHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  title: 'لا معاملات شحن في هذه الفترة',
                  subtitle: 'ستظهر معاملات shipments_wallet هنا',
                  icon: Icons.local_shipping_outlined,
                ),
              )
            else
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 300,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return ShipmentWalletCard(
                      entry: item,
                      selected:
                          controller.selectedShipmentWallet?.id == item.id,
                      isMarkingSent:
                          controller.markingShipmentSentId == item.id,
                      onTap: () => controller.selectShipmentWallet(item),
                      onMarkSent: item.isDone
                          ? () => controller
                              .confirmMarkShipmentWalletSent(item)
                          : null,
                    );
                  },
                  childCount: items.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ShipmentMoneyRequestsList extends StatelessWidget {
  const _ShipmentMoneyRequestsList({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.shipmentMoneyRequests.isEmpty) {
      return const AppEmptyState(
        title: 'لا توجد طلبات سحب',
        subtitle: 'طلبات shipment_request_money ستظهر هنا',
        icon: Icons.request_page_outlined,
      );
    }
    if (controller.filteredShipmentMoneyRequests.isEmpty) {
      return const AppEmptyState(
        title: 'لا نتائج',
        subtitle: 'عدّل كلمات البحث',
        icon: Icons.search_off,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _gridColumns(constraints.maxWidth);
        final items = controller.filteredShipmentMoneyRequests;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: 240,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ShipmentRequestMoneyCard(
              request: item,
              selected:
                  controller.selectedShipmentMoneyRequest?.id == item.id,
              isActing:
                  controller.actingShipmentMoneyRequestId == item.id,
              onTap: () => controller.selectShipmentMoneyRequest(item),
              onApprove: item.isPending
                  ? () =>
                      controller.confirmApproveShipmentMoneyRequest(item)
                  : null,
              onReject: item.isPending
                  ? () =>
                      controller.confirmRejectShipmentMoneyRequest(item)
                  : null,
            );
          },
        );
      },
    );
  }
}

class _VendorMoneyRequestsList extends StatelessWidget {
  const _VendorMoneyRequestsList({required this.controller});

  final CommissionsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.vendorMoneyRequests.isEmpty) {
      return const AppEmptyState(
        title: 'لا توجد طلبات سحب تجار',
        subtitle: 'طلبات money_requests ستظهر هنا',
        icon: Icons.storefront_outlined,
      );
    }
    if (controller.filteredVendorMoneyRequests.isEmpty) {
      return const AppEmptyState(
        title: 'لا نتائج',
        subtitle: 'عدّل كلمات البحث',
        icon: Icons.search_off,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _gridColumns(constraints.maxWidth);
        final items = controller.filteredVendorMoneyRequests;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: 260,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return VendorMoneyRequestCard(
              request: item,
              selected:
                  controller.selectedVendorMoneyRequest?.id == item.id,
              isActing:
                  controller.actingVendorMoneyRequestId == item.id,
              onTap: () => controller.selectVendorMoneyRequest(item),
              onApprove: item.isPending
                  ? () =>
                      controller.confirmApproveVendorMoneyRequest(item)
                  : null,
              onReject: item.isPending
                  ? () =>
                      controller.confirmRejectVendorMoneyRequest(item)
                  : null,
            );
          },
        );
      },
    );
  }
}
