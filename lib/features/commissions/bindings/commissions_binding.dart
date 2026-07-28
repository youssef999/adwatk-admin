import 'package:get/get.dart';

import '../controllers/commissions_controller.dart';
import '../repositories/commissions_repository.dart';

class CommissionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommissionsRepository>(CommissionsRepository.new);
    Get.lazyPut<CommissionsController>(
      () => CommissionsController(
        repository: Get.find<CommissionsRepository>(),
      ),
    );
  }
}
