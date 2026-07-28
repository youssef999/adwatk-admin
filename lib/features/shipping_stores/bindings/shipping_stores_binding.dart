import 'package:get/get.dart';

import '../controllers/shipping_stores_controller.dart';
import '../repositories/shipping_stores_repository.dart';

class ShippingStoresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShippingStoresRepository>(ShippingStoresRepository.new);
    Get.lazyPut<ShippingStoresController>(
      () => ShippingStoresController(
        repository: Get.find<ShippingStoresRepository>(),
      ),
    );
  }
}
