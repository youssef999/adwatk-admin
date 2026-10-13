import 'package:get/get.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/banners/bindings/banners_binding.dart';
import '../../features/banners/pages/banners_page.dart';
import '../../features/commissions/bindings/commissions_binding.dart';
import '../../features/commissions/pages/commissions_detail_page.dart';
import '../../features/commissions/pages/commissions_page.dart';
import '../../features/moderators/bindings/moderators_binding.dart';
import '../../features/moderators/pages/moderators_page.dart';
import '../../features/notes/bindings/notes_binding.dart';
import '../../features/notes/pages/notes_page.dart';
import '../../features/requests/bindings/requests_binding.dart';
import '../../features/requests/pages/requests_page.dart';
import '../../features/shipping_stores/bindings/shipping_stores_binding.dart';
import '../../features/shipping_stores/pages/shipping_stores_page.dart';
import '../../features/users/bindings/users_binding.dart';
import '../../features/users/pages/users_page.dart';
import '../../features/vendors/bindings/vendors_binding.dart';
import '../../features/vendors/pages/vendors_page.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';

class AppPages {
  AppPages._();

  /// Admin or shipping moderator.
  static final List<GetMiddleware> _shipping = [AuthMiddleware()];

  /// Admin only — moderators are redirected to their shipping home page.
  static final List<GetMiddleware> _adminOnly = [
    AuthMiddleware(adminOnly: true),
  ];

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.banners,
      page: () => const BannersPage(),
      binding: BannersBinding(),
      middlewares: _adminOnly,
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersPage(),
      binding: UsersBinding(),
      middlewares: _adminOnly,
    ),
    GetPage(
      name: AppRoutes.vendors,
      page: () => const VendorsPage(),
      binding: VendorsBinding(),
      middlewares: _adminOnly,
    ),
    GetPage(
      name: AppRoutes.requests,
      page: () => const RequestsPage(),
      binding: RequestsBinding(),
      middlewares: _adminOnly,
    ),
    GetPage(
      name: AppRoutes.shippingStores,
      page: () => const ShippingStoresPage(),
      binding: ShippingStoresBinding(),
      middlewares: _shipping,
    ),
    GetPage(
      name: AppRoutes.commissions,
      page: () => const CommissionsPage(),
      binding: CommissionsBinding(),
      middlewares: _shipping,
    ),
    GetPage(
      name: AppRoutes.commissionsDetail,
      page: () => const CommissionsDetailPage(),
      middlewares: _shipping,
    ),
    GetPage(
      name: AppRoutes.notes,
      page: () => const NotesPage(),
      binding: NotesBinding(),
      middlewares: _adminOnly,
    ),
    GetPage(
      name: AppRoutes.moderators,
      page: () => const ModeratorsPage(),
      binding: ModeratorsBinding(),
      middlewares: _adminOnly,
    ),
  ];
}
