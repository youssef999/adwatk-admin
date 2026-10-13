import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bindings/auth_binding.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  // On web the persisted session is restored asynchronously; wait for it so
  // route guards don't bounce a signed-in admin to the login page on refresh.
  await FirebaseAuth.instance.authStateChanges().first;
  AuthBinding().dependencies();
  await Get.find<AuthRepository>().restoreSession();
  runApp(const AdwatkControlPanelApp());
}

class AdwatkControlPanelApp extends StatelessWidget
{
  const AdwatkControlPanelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ادواتك — لوحة التحكم',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      initialRoute: AppRoutes.banners,
      getPages: AppPages.pages,
    );
  }
}
