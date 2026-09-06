import 'package:get/get.dart';

import '../controllers/notes_controller.dart';
import '../repositories/notes_repository.dart';

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotesRepository>(NotesRepository.new);
    Get.lazyPut<NotesController>(
      () => NotesController(repository: Get.find<NotesRepository>()),
    );
  }
}
