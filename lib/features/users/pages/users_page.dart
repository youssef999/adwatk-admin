import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/users_controller.dart';
import '../widgets/customer_home_visibility_section.dart';
import '../widgets/customer_form_dialog.dart';
import '../widgets/customer_list_item.dart';
import '../widgets/phone_lookup_form_dialog.dart';
import '../widgets/phone_lookup_list_item.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'المستخدمون',
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: GetBuilder<UsersController>(
            id: UsersController.listId,
            builder: (controller) {
              final isPhones =
                  controller.activeTab == UsersPageTab.phoneLinks;
              return AppButton(
                label: isPhones ? 'ربط هاتف' : 'إضافة مستخدم',
                icon: isPhones ? Icons.link : Icons.person_add_alt_1,
                onPressed: isPhones ? _openPhoneCreate : _openCreate,
              );
            },
          ),
        ),
      ],
      body: GetBuilder<UsersController>(
        id: UsersController.listId,
        builder: (controller) {
          if (controller.isLoading &&
              controller.customers.isEmpty &&
              controller.phoneLookups.isEmpty) {
            return const AppLoader(message: 'جاري تحميل المستخدمين...');
          }

          if (controller.errorMessage != null &&
              controller.customers.isEmpty &&
              controller.phoneLookups.isEmpty) {
            return AppErrorState(
              message: controller.errorMessage!,
              onRetry: controller.loadAll,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: controller.activeTab == UsersPageTab.phoneLinks
                      ? 'بحث برقم الهاتف أو البريد...'
                      : 'بحث بالاسم أو البريد أو الهاتف...',
                  hintStyle: AppTextStyles.body2,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              if (controller.activeTab == UsersPageTab.customers) ...[
                const SizedBox(height: AppSpacing.md),
                const HomeVisibilitySection(),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _UsersTab(
                      label: 'المستخدمون',
                      count: controller.filteredCustomers.length,
                      selected:
                          controller.activeTab == UsersPageTab.customers,
                      onTap: () =>
                          controller.setTab(UsersPageTab.customers),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _UsersTab(
                      label: 'ربط الهواتف',
                      count: controller.filteredPhoneLookups.length,
                      selected:
                          controller.activeTab == UsersPageTab.phoneLinks,
                      onTap: () =>
                          controller.setTab(UsersPageTab.phoneLinks),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.activeTab == UsersPageTab.phoneLinks
                          ? 'phone_lookup ← رقم الهاتف → البريد'
                          : '${controller.filteredCustomers.length} مستخدم (customer)',
                      style: AppTextStyles.body2,
                    ),
                  ),
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed: controller.loadAll,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: controller.activeTab == UsersPageTab.phoneLinks
                    ? _PhoneLinksBody(controller: controller)
                    : _CustomersBody(controller: controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCreate() async {
    final controller = Get.find<UsersController>();
    controller.prepareCreate();
    await Get.dialog<bool>(
      const CustomerFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _openPhoneCreate() async {
    final controller = Get.find<UsersController>();
    controller.preparePhoneCreate();
    await Get.dialog<bool>(
      const PhoneLookupFormDialog(),
      barrierDismissible: false,
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: selected
                      ? AppColors.surface
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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

class _CustomersBody extends StatelessWidget {
  const _CustomersBody({required this.controller});

  final UsersController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.customers.isEmpty) {
      return AppEmptyState(
        title: 'لا يوجد مستخدمون',
        subtitle: 'أضف عميلًا جديدًا بدور customer',
        icon: Icons.people_outline,
        actionLabel: 'إضافة مستخدم',
        onAction: () async {
          controller.prepareCreate();
          await Get.dialog<bool>(
            const CustomerFormDialog(),
            barrierDismissible: false,
          );
        },
      );
    }
    if (controller.filteredCustomers.isEmpty) {
      return const AppEmptyState(
        title: 'لا نتائج',
        subtitle: 'جرّب كلمات بحث أخرى',
        icon: Icons.search_off,
      );
    }

    return ListView.separated(
      itemCount: controller.filteredCustomers.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return CustomerListItem(
          customer: controller.filteredCustomers[index],
        );
      },
    );
  }
}

class _PhoneLinksBody extends StatelessWidget {
  const _PhoneLinksBody({required this.controller});

  final UsersController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.phoneLookups.isEmpty) {
      return AppEmptyState(
        title: 'لا توجد أرقام مربوطة',
        subtitle: 'اربط رقم هاتف ببريد مستخدم لتفعيل الدخول بالهاتف',
        icon: Icons.phonelink_setup,
        actionLabel: 'ربط هاتف',
        onAction: () async {
          controller.preparePhoneCreate();
          await Get.dialog<bool>(
            const PhoneLookupFormDialog(),
            barrierDismissible: false,
          );
        },
      );
    }
    if (controller.filteredPhoneLookups.isEmpty) {
      return const AppEmptyState(
        title: 'لا نتائج',
        subtitle: 'جرّب كلمات بحث أخرى',
        icon: Icons.search_off,
      );
    }

    return ListView.separated(
      itemCount: controller.filteredPhoneLookups.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return PhoneLookupListItem(
          lookup: controller.filteredPhoneLookups[index],
        );
      },
    );
  }
}
