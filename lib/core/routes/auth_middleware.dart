import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../features/auth/repositories/auth_repository.dart';
import 'app_routes.dart';

/// Blocks protected pages until an admin or moderator is signed in.
/// [adminOnly] pages send moderators back to their shipping home page.
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.adminOnly = false});

  final bool adminOnly;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthRepository>();
    if (!auth.isSignedIn) return const RouteSettings(name: AppRoutes.login);
    if (adminOnly && !auth.isAdmin) return RouteSettings(name: auth.homeRoute);
    return null;
  }
}

/// Skips the login page when a session already exists.
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthRepository>();
    if (!auth.isSignedIn) return null;
    return RouteSettings(name: auth.homeRoute);
  }
}
