import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  static const String formId = 'login_form';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSubmitting = false;
  bool obscurePassword = true;
  bool loginAsModerator = false;
  String? errorMessage;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    update([formId]);
  }

  void setLoginAsModerator(bool? value) {
    loginAsModerator = value ?? false;
    errorMessage = null;
    update([formId]);
  }

  Future<void> signIn() async {
    if (isSubmitting) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'أدخل البريد الإلكتروني وكلمة المرور.';
      update([formId]);
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    update([formId]);
    try {
      await _repository.signIn(
        email: email,
        password: password,
        asModerator: loginAsModerator,
      );
      Get.offAllNamed(_repository.homeRoute);
    } on AdminAccessDeniedException catch (e) {
      errorMessage = e.asModerator
          ? 'هذا الحساب ليس مشرفًا أو أنه موقوف.'
          : 'هذا الحساب لا يملك صلاحية دخول لوحة التحكم. إن كنت مشرفًا فعّل خيار "دخول كمشرف".';
    } on FirebaseAuthException catch (e) {
      errorMessage = _messageFor(e.code);
    } catch (e) {
      debugPrint('Admin sign-in failed: $e');
      errorMessage = 'تعذر تسجيل الدخول، حاول مرة أخرى.';
    } finally {
      isSubmitting = false;
      update([formId]);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    loginAsModerator = false;
    Get.offAllNamed(AppRoutes.login);
  }

  String _messageFor(String code) {
    return switch (code) {
      'invalid-email' => 'البريد الإلكتروني غير صالح.',
      'user-disabled' => 'هذا الحساب موقوف.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'too-many-requests' => 'محاولات كثيرة، حاول لاحقًا.',
      'network-request-failed' => 'تحقق من اتصال الإنترنت.',
      _ => 'تعذر تسجيل الدخول، حاول مرة أخرى. ($code)',
    };
  }
}
