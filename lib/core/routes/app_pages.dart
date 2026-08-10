import 'package:get/get.dart';

import '../../features/banners/bindings/banners_binding.dart';
import '../../features/banners/pages/banners_page.dart';
import '../../features/commissions/bindings/commissions_binding.dart';
import '../../features/commissions/pages/commissions_detail_page.dart';
import '../../features/commissions/pages/commissions_page.dart';
import '../../features/requests/bindings/requests_binding.dart';
import '../../features/requests/pages/requests_page.dart';
import '../../features/shipping_stores/bindings/shipping_stores_binding.dart';
import '../../features/shipping_stores/pages/shipping_stores_page.dart';
import '../../features/users/bindings/users_binding.dart';
import '../../features/users/pages/users_page.dart';
import '../../features/vendors/bindings/vendors_binding.dart';
import '../../features/vendors/pages/vendors_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.banners,
      page: () => const BannersPage(),
      binding: BannersBinding(),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersPage(),
      binding: UsersBinding(),
    ),
    GetPage(
      name: AppRoutes.vendors,
      page: () => const VendorsPage(),
      binding: VendorsBinding(),
    ),
    GetPage(
      name: AppRoutes.requests,
      page: () => const RequestsPage(),
      binding: RequestsBinding(),
    ),
    GetPage(
      name: AppRoutes.shippingStores,
      page: () => const ShippingStoresPage(),
      binding: ShippingStoresBinding(),
    ),
    GetPage(
      name: AppRoutes.commissions,
      page: () => const CommissionsPage(),
      binding: CommissionsBinding(),
    ),
    GetPage(
      name: AppRoutes.commissionsDetail,
      page: () => const CommissionsDetailPage(),
    ),
  ];
}
