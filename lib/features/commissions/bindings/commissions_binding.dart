import 'package:get/get.dart';

import '../../auth/repositories/auth_repository.dart';
import '../controllers/commissions_controller.dart';
import '../repositories/commissions_repository.dart';

class CommissionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommissionsRepository>(CommissionsRepository.new);
    Get.lazyPut<CommissionsController>(
      () => CommissionsController(
        repository: Get.find<CommissionsRepository>(),
        shippingOnly: Get.find<AuthRepository>().isModerator,
      ),
    );
  }
}
