import 'package:get/get.dart';

import '../routes/app_routes.dart';

class DeepLinkNavigation {
  DeepLinkNavigation._();

  static void openRequest({
    required String requestId,
    String? offerId,
  }) {
    if (requestId.trim().isEmpty) return;
    Get.toNamed(
      AppRoutes.requests,
      arguments: {
        'requestId': requestId.trim(),
        if (offerId != null && offerId.trim().isNotEmpty)
          'offerId': offerId.trim(),
      },
    );
  }

  static void openVendor({required String vendorId}) {
    if (vendorId.trim().isEmpty) return;
    Get.toNamed(
      AppRoutes.vendors,
      arguments: {'vendorId': vendorId.trim()},
    );
  }
}
