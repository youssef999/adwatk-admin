import 'package:get/get.dart';

import '../controllers/requests_controller.dart';
import '../repositories/requests_repository.dart';

class RequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestsRepository>(RequestsRepository.new);
    Get.lazyPut<RequestsController>(
      () => RequestsController(repository: Get.find<RequestsRepository>()),
    );
  }
}
