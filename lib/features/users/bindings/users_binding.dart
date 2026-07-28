import 'package:get/get.dart';

import '../controllers/users_controller.dart';
import '../repositories/users_repository.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersRepository>(UsersRepository.new, fenix: true);
    Get.lazyPut<UsersController>(
      () => UsersController(repository: Get.find<UsersRepository>()),
    );
  }
}
