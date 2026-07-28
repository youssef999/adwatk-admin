import 'package:get/get.dart';

import '../controllers/banners_controller.dart';
import '../repositories/banners_repository.dart';

class BannersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BannersRepository>(BannersRepository.new);
    Get.lazyPut<BannersController>(
      () => BannersController(repository: Get.find<BannersRepository>()),
    );
  }
}
