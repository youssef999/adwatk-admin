import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

/// Registered from `main()` before `runApp` so the session role is known to
/// route guards, and sign-out is reachable from every page.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Permanent: holds the signed-in role for the whole app lifetime.
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.lazyPut<AuthController>(
      () => AuthController(repository: Get.find<AuthRepository>()),
      fenix: true,
    );
  }
}
