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
import '../controllers/requests_controller.dart';
import '../widgets/request_detail_panel.dart';
import '../widgets/request_list_tile.dart';
import '../widgets/sale_part_detail_panel.dart';
import '../widgets/sale_part_list_tile.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.applyRouteArguments();
    });

    return AppScaffold(
      title: 'الطلبات والعروض',
      actions: [
        IconButton(
          tooltip: 'تحديث',
          onPressed: controller.loadRequests,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = !Breakpoints.isMobile(constraints.maxWidth);

          return GetBuilder<RequestsController>(
            id: RequestsController.listId,
            builder: (controller) {
              if (controller.isLoading &&
                  controller.requests.isEmpty &&
                  controller.saleParts.isEmpty) {
                return const AppLoader(message: 'جاري تحميل الطلبات...');
              }

              if (controller.errorMessage != null &&
                  controller.requests.isEmpty &&
                  controller.saleParts.isEmpty) {
                return AppErrorState(
                  message: controller.errorMessage!,
                  onRetry: controller.loadRequests,
                );
              }

              final hasSelection = controller.selectedRequest != null ||
                  controller.selectedSalePart != null;

              if (!isWide && hasSelection) {
                if (controller.selectedSalePart != null) {
                  return const SalePartDetailPanel(showBack: true);
                }
                return const RequestDetailPanel(showBack: true);
              }

              final listPane = _RequestsListPane(controller: controller);

              if (!isWide) return listPane;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: constraints.maxWidth < Breakpoints.tablet
                        ? 320
                        : 380,
                    child: listPane,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: controller.sourceTab == RequestsSourceTab.saleParts
                        ? const SalePartDetailPanel()
                        : const RequestDetailPanel(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _RequestsListPane extends StatelessWidget {
  const _RequestsListPane({required this.controller});

  final RequestsController controller;

  @override
  Widget build(BuildContext context) {
    final isSaleParts = controller.sourceTab == RequestsSourceTab.saleParts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _SourceTab(
                label: 'طلبات عادية',
                count: controller.filteredRequests.length,
                selected: !isSaleParts,
                onTap: () =>
                    controller.setSourceTab(RequestsSourceTab.requests),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SourceTab(
                label: 'قطع للبيع',
                count: controller.filteredSaleParts.length,
                selected: isSaleParts,
                onTap: () =>
                    controller.setSourceTab(RequestsSourceTab.saleParts),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: isSaleParts
                ? 'بحث بالقطعة، البائع، الماركة...'
                : 'بحث بالقطعة، الوصف، الماركة، VIN...',
            hintStyle: AppTextStyles.body2,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'الكل',
                selected: controller.statusFilter == 'all',
                onTap: () => controller.setStatusFilter('all'),
              ),
              ...controller.availableStatuses.map(
                (status) => _FilterChip(
                  label: status,
                  selected: controller.statusFilter == status,
                  onTap: () => controller.setStatusFilter(status),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          isSaleParts
              ? '${controller.filteredSaleParts.length} قطعة'
              : '${controller.filteredRequests.length} طلب',
          style: AppTextStyles.body2,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: isSaleParts
              ? _SalePartsList(controller: controller)
              : _RequestsList(controller: controller),
        ),
      ],
    );
  }
}

class _SourceTab extends StatelessWidget {
  const _SourceTab({
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
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
                style: AppTextStyles.body2.copyWith(
                  color: selected
                      ? AppColors.surface
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 72),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: selected
                      ? AppColors.surface
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.controller});

  final RequestsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.requests.isEmpty) {
      return const AppEmptyState(
        title: 'لا توجد طلبات',
        subtitle: 'ستظهر طلبات العملاء هنا عند إنشائها',
        icon: Icons.assignment_outlined,
      );
    }
    if (controller.filteredRequests.isEmpty) {
      return const AppEmptyState(
        title: 'لا نتائج',
        subtitle: 'عدّل البحث أو فلتر الحالة',
        icon: Icons.search_off,
      );
    }

    return ListView.separated(
      itemCount: controller.filteredRequests.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final request = controller.filteredRequests[index];
        return RequestListTile(
          request: request,
          selected: controller.selectedRequest?.id == request.id,
          onTap: () => controller.selectRequest(request),
        );
      },
    );
  }
}

class _SalePartsList extends StatelessWidget {
  const _SalePartsList({required this.controller});

  final RequestsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.saleParts.isEmpty) {
      return const AppEmptyState(
        title: 'لا توجد قطع للبيع',
        subtitle: 'عناصر sale_parts ستظهر هنا',
        icon: Icons.storefront_outlined,
      );
    }
    if (controller.filteredSaleParts.isEmpty) {
      return const AppEmptyState(
        title: 'لا نتائج',
        subtitle: 'عدّل البحث أو فلتر الحالة',
        icon: Icons.search_off,
      );
    }

    return ListView.separated(
      itemCount: controller.filteredSaleParts.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final part = controller.filteredSaleParts[index];
        return SalePartListTile(
          part: part,
          selected: controller.selectedSalePart?.id == part.id,
          onTap: () => controller.selectSalePart(part),
        );
      },
    );
  }
}
