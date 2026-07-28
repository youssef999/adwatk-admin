import 'package:get/get.dart';

import '../../users/repositories/users_repository.dart';
import '../controllers/vendors_controller.dart';

class VendorsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsersRepository>()) {
      Get.lazyPut<UsersRepository>(UsersRepository.new, fenix: true);
    }
    Get.lazyPut<VendorsController>(
      () => VendorsController(repository: Get.find<UsersRepository>()),
    );
  }
}
