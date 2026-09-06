
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
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
