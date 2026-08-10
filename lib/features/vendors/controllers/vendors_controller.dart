import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/services/notifications_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/feedback/send_notification_dialog.dart';
import '../../users/repositories/users_repository.dart';
import '../models/vendor_model.dart';

class VendorsController extends GetxController {
  VendorsController({
    UsersRepository? repository,
    NotificationsService? notificationsService,
  })  : _repository = repository ?? UsersRepository(),
        _notifications = notificationsService ?? NotificationsService();

  final UsersRepository _repository;
  final NotificationsService _notifications;

  static const String listId = 'vendors_list';
  static const String formId = 'vendors_form';
  static const String financeFormId = 'vendors_finance_form';

  final shopNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final specializationsController = TextEditingController();
  final minWalletAlertController = TextEditingController();
  final financeAmountController = TextEditingController();
  final financeMinAlertController = TextEditingController();
  final searchController = TextEditingController();

  List<VendorModel> vendors = [];
  Map<String, num> walletBalances = {};
  Map<String, num> minWalletAlerts = {};
  String searchQuery = '';
  String selectedRole = UserRoles.worker;
  String? focusedVendorId;
  bool isLoading = false;
  bool isSubmitting = false;
  bool isAdjustingFinance = false;
  String? errorMessage;
  VendorModel? editingVendor;
  VendorModel? financeVendor;

  List<VendorModel> get filteredVendors {
    Iterable<VendorModel> list = vendors;

    if (focusedVendorId != null && focusedVendorId!.isNotEmpty) {
      list = list.where(
        (v) => v.uid == focusedVendorId || v.id == focusedVendorId,
      );
    }

    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list.toList();
    return list.where((v) {
      return v.shopName.toLowerCase().contains(q) ||
          v.email.toLowerCase().contains(q) ||
          v.phoneNumber.contains(q) ||
          v.address.toLowerCase().contains(q) ||
          v.uid.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    applyRouteArguments(reload: false);
    loadVendors();
  }

  void applyRouteArguments({bool reload = true}) {
    final args = Get.arguments;
    final newFocus = (args is Map && args['vendorId'] is String)
        ? (args['vendorId'] as String).trim()
        : null;
    if (newFocus == focusedVendorId) return;
    focusedVendorId = newFocus;
    if (reload) update([listId]);
  }

  void clearVendorFocus() {
    focusedVendorId = null;
    update([listId]);
  }

  String _vendorKey(VendorModel vendor) =>
      vendor.uid.isNotEmpty ? vendor.uid : vendor.id;

  num walletAmountFor(VendorModel vendor) =>
      walletBalances[_vendorKey(vendor)] ?? 0;

  num? minWalletAlertFor(VendorModel vendor) =>
      minWalletAlerts[_vendorKey(vendor)];

  @override
  void onClose() {
    shopNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    latController.dispose();
    lngController.dispose();
    specializationsController.dispose();
    minWalletAlertController.dispose();
    financeAmountController.dispose();
    financeMinAlertController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadVendors() async {
    isLoading = true;
    errorMessage = null;
    update([listId]);

    try {
      final results = await Future.wait([
        _repository.fetchVendors(),
        _repository.fetchVendorWalletBalances(),
        _repository.fetchAllProviderMinWalletAlerts(),
      ]);
      vendors = results[0] as List<VendorModel>;
      walletBalances = results[1] as Map<String, num>;
      minWalletAlerts = results[2] as Map<String, num>;
    } catch (_) {
      errorMessage = 'تعذر تحميل البائعين. حاول مرة أخرى.';
    } finally {
      isLoading = false;
      update([listId]);
    }
  }

  void prepareFinance(VendorModel vendor) {
    financeVendor = vendor;
    financeAmountController.clear();
    final alert = minWalletAlertFor(vendor);
    financeMinAlertController.text = alert?.toString() ?? '';
    update([financeFormId]);
  }

  bool isFinanceNegativeRestricted(VendorModel vendor) {
    final alert = minWalletAlertFor(vendor);
    return alert != null && alert == 0;
  }

  Future<void> setFinanceNegativeRestricted(bool restricted) async {
    final vendor = financeVendor;
    if (vendor == null) return;

    final value = restricted ? 0 : 50000;
    isAdjustingFinance = true;
    update([financeFormId]);

    try {
      final key = _vendorKey(vendor);
      await _repository.upsertProviderMinWalletAlert(
        providerId: key,
        email: vendor.email,
        value: value,
      );
      minWalletAlerts[key] = value;
      financeMinAlertController.text = value.toString();
      AppSnackbar.success(
        restricted
            ? 'تم تقييد الرصيد السالب — الحد = 0'
            : 'تم إلغاء التقييد — الحد = 50000',
      );
      update([listId, financeFormId]);
    } catch (_) {
      AppSnackbar.error('تعذر تحديث تقييد الرصيد السالب.');
    } finally {
      isAdjustingFinance = false;
      update([financeFormId]);
    }
  }

  Future<bool> adjustVendorWallet({required bool isAdd}) async {
    final vendor = financeVendor;
    if (vendor == null) return false;

    final raw = financeAmountController.text.trim().replaceAll(',', '.');
    final amount = num.tryParse(raw);
    if (amount == null || amount <= 0) {
      AppSnackbar.error('أدخل مبلغًا أكبر من صفر.');
      return false;
    }

    isAdjustingFinance = true;
    update([financeFormId]);

    try {
      final delta = isAdd ? amount : -amount;
      final key = _vendorKey(vendor);
      await _repository.adjustVendorWalletBalance(
        vendorId: key,
        delta: delta,
      );
      walletBalances[key] = (walletBalances[key] ?? 0) + delta;
      AppSnackbar.success(
        isAdd ? 'تم إضافة المبلغ إلى محفظة التاجر.' : 'تم خصم المبلغ من محفظة التاجر.',
      );
      update([listId, financeFormId]);
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر تعديل محفظة التاجر.');
      return false;
    } finally {
      isAdjustingFinance = false;
      update([financeFormId]);
    }
  }

  Future<bool> saveFinanceMinAlert() async {
    final vendor = financeVendor;
    if (vendor == null) return false;

    final raw = financeMinAlertController.text.trim().replaceAll(',', '.');
    final value = num.tryParse(raw);
    if (value == null || value < 0) {
      AppSnackbar.error('أدخل حدًا أقصى صالحًا.');
      return false;
    }

    isAdjustingFinance = true;
    update([financeFormId]);

    try {
      final key = _vendorKey(vendor);
      await _repository.upsertProviderMinWalletAlert(
        providerId: key,
        email: vendor.email,
        value: value,
      );
      minWalletAlerts[key] = value;
      AppSnackbar.success('تم حفظ الحد الأقصى في السالب.');
      update([listId, financeFormId]);
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر حفظ الحد الأقصى.');
      return false;
    } finally {
      isAdjustingFinance = false;
      update([financeFormId]);
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    update([listId]);
  }

  void prepareCreate() {
    editingVendor = null;
    selectedRole = UserRoles.worker;
    shopNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    latController.clear();
    lngController.clear();
    specializationsController.clear();
    minWalletAlertController.clear();
    update([formId]);
  }

  Future<void> prepareEdit(VendorModel vendor) async {
    editingVendor = vendor;
    selectedRole = vendor.role;
    shopNameController.text = vendor.shopName;
    emailController.text = vendor.email;
    phoneController.text = vendor.phoneNumber;
    addressController.text = vendor.address;
    latController.text = vendor.shopLat.toString();
    lngController.text = vendor.shopLng.toString();
    specializationsController.text = vendor.specializations.join(', ');
    minWalletAlertController.clear();
    update([formId]);

    try {
      final value = await _repository.fetchProviderMinWalletAlert(
        providerId: vendor.uid.isNotEmpty ? vendor.uid : vendor.id,
        email: vendor.email,
      );
      if (editingVendor?.id != vendor.id) return;
      minWalletAlertController.text =
          value == null ? '' : value.toString();
      update([formId]);
    } catch (_) {
      // Keep form usable even if alert fetch fails.
    }
  }

  void setRole(String role) {
    selectedRole = role;
    update([formId]);
  }

  List<String> _parseSpecializations(String raw) {
    return raw
        .split(RegExp(r'[,،]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<bool> submitForm() async {
    final shopName = shopNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final lat = double.tryParse(latController.text.trim());
    final lng = double.tryParse(lngController.text.trim());
    final specs = _parseSpecializations(specializationsController.text);

    if (shopName.isEmpty) {
      AppSnackbar.error('اسم المحل مطلوب.');
      return false;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppSnackbar.error('أدخل بريدًا إلكترونيًا صالحًا.');
      return false;
    }
    if (phone.isEmpty) {
      AppSnackbar.error('رقم الهاتف مطلوب.');
      return false;
    }
    if (address.isEmpty) {
      AppSnackbar.error('العنوان مطلوب.');
      return false;
    }
    if (lat == null || lng == null) {
      AppSnackbar.error('أدخل إحداثيات صحيحة (خط العرض والطول).');
      return false;
    }

    final alertRaw = minWalletAlertController.text.trim().replaceAll(',', '.');
    num? minWalletAlert;
    if (alertRaw.isNotEmpty) {
      minWalletAlert = num.tryParse(alertRaw);
      if (minWalletAlert == null) {
        AppSnackbar.error('أدخل حدًا أقصى صالحًا للمحفظة السالبة.');
        return false;
      }
    }

    isSubmitting = true;
    update([formId]);

    try {
      late final VendorModel savedVendor;
      if (editingVendor != null) {
        savedVendor = await _repository.updateVendor(
          editingVendor!.copyWith(
            shopName: shopName,
            email: email,
            phoneNumber: phone,
            address: address,
            shopLat: lat,
            shopLng: lng,
            specializations: specs,
            role: selectedRole,
          ),
          previousPhone: editingVendor!.phoneNumber,
        );
        AppSnackbar.success('تم تحديث البائع بنجاح.');
      } else {
        savedVendor = await _repository.createVendor(
          email: email,
          phoneNumber: phone,
          role: selectedRole,
          shopName: shopName,
          address: address,
          shopLat: lat,
          shopLng: lng,
          specializations: specs,
        );
        AppSnackbar.success('تم إضافة البائع بنجاح.');
      }
      if (minWalletAlert != null) {
        final providerId =
            savedVendor.uid.isNotEmpty ? savedVendor.uid : savedVendor.id;
        await _repository.upsertProviderMinWalletAlert(
          providerId: providerId,
          email: email,
          value: minWalletAlert,
        );
      }
      await loadVendors();
      return true;
    } catch (_) {
      AppSnackbar.error('فشلت العملية. تحقق من الاتصال والصلاحيات.');
      return false;
    } finally {
      isSubmitting = false;
      update([formId]);
    }
  }

  Future<void> deleteVendor(VendorModel vendor) async {
    try {
      await _repository.deleteUser(vendor.id, phoneNumber: vendor.phoneNumber);
      vendors.removeWhere((v) => v.id == vendor.id);
      update([listId]);
      AppSnackbar.success('تم حذف البائع.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف البائع.');
    }
  }

  Future<void> openSendNotification(VendorModel vendor) async {
    final recipientId =
        vendor.uid.trim().isNotEmpty ? vendor.uid.trim() : vendor.id;
    final hasToken = (vendor.fcmToken ?? '').trim().isNotEmpty;

    final ok = await Get.dialog<bool>(
      SendNotificationDialog(
        recipientLabel:
            vendor.shopName.isEmpty ? vendor.email : vendor.shopName,
        hasFcmToken: hasToken,
        onSend: (title, body) async {
          final result = await _notifications.sendAdminNotification(
            recipientId: recipientId,
            fcmToken: vendor.fcmToken,
            title: title,
            body: body,
          );
          if (result.firestoreSaved && result.fcmSent) return true;
          if (result.firestoreSaved && !hasToken) return true;
          AppSnackbar.error(result.error ?? 'تعذر إرسال الإشعار');
          return false;
        },
      ),
      barrierDismissible: false,
    );

    if (ok == true) {
      AppSnackbar.success('تم وصول الإشعار بنجاح');
    }
  }
}
