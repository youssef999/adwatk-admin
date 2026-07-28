import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../branding/app_logo.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

        final content = Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            titleSpacing: isDesktop ? AppSpacing.lg : 0,
            title: Row(
              children: [
                if (!isDesktop) ...[
                  const AppLogo(variant: AppLogoVariant.mark, height: 32),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: actions,
            leading: isDesktop
                ? null
                : Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, size: AppIconSize.lg),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
          ),
          drawer: isDesktop ? null : const _AppDrawer(),
          floatingActionButton: floatingActionButton,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop) const _Sidebar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: body,
                ),
              ),
            ],
          ),
        );

        return Directionality(
          textDirection: TextDirection.rtl,
          child: content,
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BrandHeader(),
          Divider(height: 1),
          SizedBox(height: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.image_outlined,
                    label: 'البنرات',
                    route: AppRoutes.banners,
                  ),
                  _NavItem(
                    icon: Icons.assignment_outlined,
                    label: 'الطلبات',
                    route: AppRoutes.requests,
                  ),
                  _NavItem(
                    icon: Icons.payments_outlined,
                    label: 'العمولات والأرباح',
                    route: AppRoutes.commissions,
                  ),
                  _NavItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'متاجر الشحن',
                    route: AppRoutes.shippingStores,
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    label: 'المستخدمون',
                    route: AppRoutes.users,
                  ),
                  _NavItem(
                    icon: Icons.storefront_outlined,
                    label: 'البائعون',
                    route: AppRoutes.vendors,
                  ),
                ],
              ),
            ),
          ),
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.surface,
          ],
        ),
      ),
      child: const Column(
        children: [
          AppLogo(variant: AppLogoVariant.full, height: 88, showTagline: true),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Text(
        'ادواتك © ${DateTime.now().year}',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption,
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BrandHeader(),
            Divider(height: 1),
            SizedBox(height: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _NavItem(
                      icon: Icons.image_outlined,
                      label: 'البنرات',
                      route: AppRoutes.banners,
                    ),
                    _NavItem(
                      icon: Icons.assignment_outlined,
                      label: 'الطلبات',
                      route: AppRoutes.requests,
                    ),
                    _NavItem(
                      icon: Icons.payments_outlined,
                      label: 'العمولات والأرباح',
                      route: AppRoutes.commissions,
                    ),
                    _NavItem(
                      icon: Icons.local_shipping_outlined,
                      label: 'متاجر الشحن',
                      route: AppRoutes.shippingStores,
                    ),
                    _NavItem(
                      icon: Icons.people_outline,
                      label: 'المستخدمون',
                      route: AppRoutes.users,
                    ),
                    _NavItem(
                      icon: Icons.storefront_outlined,
                      label: 'البائعون',
                      route: AppRoutes.vendors,
                    ),
                  ],
                ),
              ),
            ),
            _SidebarFooter(),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final selected = Get.currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.12) : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: selected
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: AppIconSize.md,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: AppTextStyles.body1.copyWith(
            color: selected ? AppColors.primaryDark : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        selected: selected,
        onTap: () {
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
            Get.back();
          }
          if (Get.currentRoute != route) {
            Get.offNamed(route);
          }
        },
      ),
    );
  }
}
