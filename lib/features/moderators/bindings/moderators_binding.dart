import 'package:get/get.dart';

import '../controllers/moderators_controller.dart';
import '../repositories/moderators_repository.dart';

class ModeratorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModeratorsRepository>(ModeratorsRepository.new);
    Get.lazyPut<ModeratorsController>(
      () => ModeratorsController(
        repository: Get.find<ModeratorsRepository>(),
      ),
    );
  }
}
