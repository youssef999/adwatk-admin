import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/moderator_model.dart';
import '../repositories/moderators_repository.dart';

class ModeratorsController extends GetxController {
  ModeratorsController({ModeratorsRepository? repository})
      : _repository = repository ?? ModeratorsRepository();

  final ModeratorsRepository _repository;

  static const String listId = 'moderators_list';
  static const String formId = 'moderators_form';

  /// Firebase Auth minimum password length.
  static const int minPasswordLength = 6;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  List<ModeratorModel> moderators = [];
  ModeratorModel? editing;
  bool formActive = true;
  bool obscurePassword = true;
  bool isLoading = true;
  bool isSubmitting = false;
  String? togglingId;
  String? errorMessage;

  StreamSubscription<List<ModeratorModel>>? _subscription;

  /// New moderators, or ones whose Auth account isn't ready, need a password.
  bool get passwordRequired => editing == null || !editing!.isReady;

  @override
  void onInit() {
    super.onInit();
    listen();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void listen() {
    _subscription?.cancel();
    isLoading = true;
    errorMessage = null;
    update([listId]);
    _subscription = _repository.watchModerators().listen(
      (list) {
        moderators = list;
        isLoading = false;
        errorMessage = null;
        update([listId]);
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'تعذر تحميل المشرفين.';
        update([listId]);
      },
    );
  }

  void prepareCreate() {
    editing = null;
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    formActive = true;
    obscurePassword = true;
    update([formId]);
  }

  void prepareEdit(ModeratorModel moderator) {
    editing = moderator;
    nameController.text = moderator.name;
    emailController.text = moderator.email;
    passwordController.clear();
    formActive = moderator.active;
    obscurePassword = true;
    update([formId]);
  }

  void setFormActive(bool value) {
    formActive = value;
    update([formId]);
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    update([formId]);
  }

  Future<bool> submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (name.isEmpty) {
      AppSnackbar.error('أدخل اسم المشرف.');
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      AppSnackbar.error('أدخل بريدًا إلكترونيًا صحيحًا.');
      return false;
    }
    if (passwordRequired && password.isEmpty) {
      AppSnackbar.error('أدخل كلمة المرور.');
      return false;
    }
    if (password.isNotEmpty && password.length < minPasswordLength) {
      AppSnackbar.error(
        'كلمة المرور يجب ألا تقل عن $minPasswordLength أحرف.',
      );
      return false;
    }
    final duplicate = moderators.any(
      (m) => m.email == email && m.id != editing?.id,
    );
    if (duplicate) {
      AppSnackbar.error('يوجد مشرف بنفس البريد الإلكتروني.');
      return false;
    }

    isSubmitting = true;
    update([formId]);
    try {
      final current = editing;
      if (current == null) {
        await _repository.createModerator(
          email: email,
          name: name,
          password: password,
          active: formActive,
        );
        AppSnackbar.success('تمت إضافة المشرف — جاري تفعيل الحساب.');
      } else {
        await _repository.updateModerator(
          id: current.id,
          email: email,
          name: name,
          active: formActive,
          password: password.isEmpty ? null : password,
        );
        AppSnackbar.success('تم حفظ بيانات المشرف.');
      }
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر حفظ المشرف.');
      return false;
    } finally {
      isSubmitting = false;
      update([formId]);
    }
  }

  Future<void> toggleActive(ModeratorModel moderator) async {
    togglingId = moderator.id;
    update([listId]);
    try {
      await _repository.setActive(moderator.id, !moderator.active);
      AppSnackbar.success(
        moderator.active ? 'تم إيقاف المشرف.' : 'تم تفعيل المشرف.',
      );
    } catch (_) {
      AppSnackbar.error('تعذر تحديث حالة المشرف.');
    } finally {
      togglingId = null;
      update([listId]);
    }
  }

  Future<void> confirmDelete(ModeratorModel moderator) async {
    final label = moderator.name.isEmpty ? moderator.email : moderator.name;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('حذف مشرف', style: AppTextStyles.h5),
        content: Text(
          'سيتم حذف "$label" ولن يستطيع الدخول للوحة التحكم مرة أخرى.',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'حذف',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteModerator(moderator.id);
      AppSnackbar.success('تم حذف المشرف.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف المشرف.');
    }
  }
}
