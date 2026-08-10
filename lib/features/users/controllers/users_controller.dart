import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/feedback/send_notification_dialog.dart';
import '../../../core/services/notifications_service.dart';
import '../models/customer_model.dart';
import '../models/phone_lookup_model.dart';
import '../models/user_wallet_model.dart';
import '../repositories/users_repository.dart';

enum UsersPageTab { customers, phoneLinks }

class UsersController extends GetxController {
  UsersController({
    UsersRepository? repository,
    NotificationsService? notificationsService,
  })  : _repository = repository ?? UsersRepository(),
        _notifications = notificationsService ?? NotificationsService();

  final UsersRepository _repository;
  final NotificationsService _notifications;

  static const String listId = 'users_list';
  static const String formId = 'users_form';
  static const String phoneFormId = 'phone_form';
  static const String walletFormId = 'users_wallet_form';

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final minWalletAlertController = TextEditingController();
  final walletAmountController = TextEditingController();
  final walletMinAlertController = TextEditingController();
  final searchController = TextEditingController();
  final lookupPhoneController = TextEditingController();
  final lookupEmailController = TextEditingController();

  UsersPageTab activeTab = UsersPageTab.customers;
  List<CustomerModel> customers = [];
  List<PhoneLookupModel> phoneLookups = [];
  List<UserWalletModel> userWallets = [];
  Map<String, num> minWalletAlerts = {};
  String searchQuery = '';
  bool isLoading = false;
  bool isSubmitting = false;
  bool isAdjustingWallet = false;
  String? errorMessage;
  CustomerModel? editingCustomer;
  CustomerModel? walletCustomer;
  PhoneLookupModel? editingPhoneLookup;

  List<CustomerModel> get filteredCustomers {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return customers;
    return customers.where((c) {
      return c.fullName.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.phoneNumber.contains(q);
    }).toList();
  }

  List<PhoneLookupModel> get filteredPhoneLookups {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return phoneLookups;
    return phoneLookups.where((p) {
      return p.phone.contains(q) || p.email.toLowerCase().contains(q);
    }).toList();
  }

  /// phone → email from phone_lookup
  Map<String, String> get phoneToEmail {
    return {for (final p in phoneLookups) p.phone.trim(): p.email.trim()};
  }

  bool isPhoneLinked(CustomerModel customer) {
    final phone = customer.phoneNumber.trim();
    if (phone.isEmpty) return false;
    final linkedEmail = phoneToEmail[phone];
    if (linkedEmail == null || linkedEmail.isEmpty) return false;
    return linkedEmail.toLowerCase() == customer.email.trim().toLowerCase();
  }

  CustomerModel? customerForLookup(PhoneLookupModel lookup) {
    final email = lookup.email.trim().toLowerCase();
    final phone = lookup.phone.trim();
    for (final c in customers) {
      if (c.email.trim().toLowerCase() == email ||
          c.phoneNumber.trim() == phone) {
        return c;
      }
    }
    return null;
  }

  UserWalletModel? walletFor(CustomerModel customer) {
    final uid = customer.uid.trim();
    final id = customer.id.trim();
    final email = customer.email.trim().toLowerCase();

    for (final w in userWallets) {
      final walletUserId = w.userId.trim();
      if (walletUserId.isNotEmpty &&
          (walletUserId == uid || walletUserId == id)) {
        return w;
      }
    }
    for (final w in userWallets) {
      if (w.userEmail.trim().toLowerCase() == email && email.isNotEmpty) {
        return w;
      }
    }
    return null;
  }

  num walletAmountFor(CustomerModel customer) =>
      walletFor(customer)?.amount ?? 0;

  num? minWalletAlertFor(CustomerModel customer) {
    final email = customer.email.trim().toLowerCase();
    if (email.isEmpty) return null;
    return minWalletAlerts[email];
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    minWalletAlertController.dispose();
    walletAmountController.dispose();
    walletMinAlertController.dispose();
    searchController.dispose();
    lookupPhoneController.dispose();
    lookupEmailController.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    update([listId]);

    try {
      final results = await Future.wait([
        _repository.fetchCustomers(),
        _repository.fetchPhoneLookups(),
        _repository.fetchUserWallets(),
        _repository.fetchAllUserMinWalletAlerts(),
      ]);
      customers = results[0] as List<CustomerModel>;
      phoneLookups = results[1] as List<PhoneLookupModel>;
      userWallets = results[2] as List<UserWalletModel>;
      minWalletAlerts = results[3] as Map<String, num>;
    } catch (_) {
      errorMessage = 'تعذر تحميل المستخدمين. حاول مرة أخرى.';
    } finally {
      isLoading = false;
      update([listId]);
    }
  }

  void prepareWalletAdjust(CustomerModel customer) {
    walletCustomer = customer;
    walletAmountController.clear();
    final alert = minWalletAlertFor(customer);
    walletMinAlertController.text = alert?.toString() ?? '';
    update([walletFormId]);
  }

  bool isWalletNegativeRestricted(CustomerModel customer) {
    final alert = minWalletAlertFor(customer);
    return alert != null && alert == 0;
  }

  Future<void> setWalletNegativeRestricted(bool restricted) async {
    final customer = walletCustomer;
    if (customer == null) return;

    final value = restricted ? 0 : 50000;
    isAdjustingWallet = true;
    update([walletFormId]);

    try {
      await _repository.upsertMinWalletAlert(
        userEmail: customer.email,
        value: value,
      );
      minWalletAlerts[customer.email.trim().toLowerCase()] = value;
      walletMinAlertController.text = value.toString();
      AppSnackbar.success(
        restricted
            ? 'تم تقييد الرصيد السالب — الحد = 0'
            : 'تم إلغاء التقييد — الحد = 50000',
      );
      update([listId, walletFormId]);
    } catch (_) {
      AppSnackbar.error('تعذر تحديث تقييد الرصيد السالب.');
    } finally {
      isAdjustingWallet = false;
      update([walletFormId]);
    }
  }

  Future<bool> saveWalletMinAlert() async {
    final customer = walletCustomer;
    if (customer == null) return false;

    final raw = walletMinAlertController.text.trim().replaceAll(',', '.');
    final value = num.tryParse(raw);
    if (value == null || value < 0) {
      AppSnackbar.error('أدخل حدًا أقصى صالحًا.');
      return false;
    }

    isAdjustingWallet = true;
    update([walletFormId]);

    try {
      await _repository.upsertMinWalletAlert(
        userEmail: customer.email,
        value: value,
      );
      minWalletAlerts[customer.email.trim().toLowerCase()] = value;
      AppSnackbar.success('تم حفظ الحد الأقصى في السالب.');
      update([listId, walletFormId]);
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر حفظ الحد الأقصى.');
      return false;
    } finally {
      isAdjustingWallet = false;
      update([walletFormId]);
    }
  }

  Future<bool> adjustWallet({required bool isAdd}) async {
    final customer = walletCustomer;
    if (customer == null) return false;

    final raw = walletAmountController.text.trim().replaceAll(',', '.');
    final amount = num.tryParse(raw);
    if (amount == null || amount <= 0) {
      AppSnackbar.error('أدخل مبلغًا أكبر من صفر.');
      return false;
    }

    isAdjustingWallet = true;
    update([walletFormId]);

    try {
      final delta = isAdd ? amount : -amount;
      final userId = customer.uid.isNotEmpty ? customer.uid : customer.id;
      final updated = await _repository.adjustUserWallet(
        userId: userId,
        userEmail: customer.email,
        delta: delta,
      );

      final index = userWallets.indexWhere((w) => w.docId == updated.docId);
      if (index >= 0) {
        userWallets[index] = updated;
      } else {
        userWallets = [...userWallets, updated];
      }

      AppSnackbar.success(
        isAdd ? 'تم إضافة المبلغ إلى المحفظة.' : 'تم خصم المبلغ من المحفظة.',
      );
      update([listId, walletFormId]);
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر تعديل المحفظة. تحقق من الاتصال والصلاحيات.');
      return false;
    } finally {
      isAdjustingWallet = false;
      update([walletFormId]);
    }
  }

  Future<void> loadCustomers() => loadAll();

  void setTab(UsersPageTab tab) {
    if (activeTab == tab) return;
    activeTab = tab;
    update([listId]);
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    update([listId]);
  }

  void prepareCreate() {
    editingCustomer = null;
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    minWalletAlertController.clear();
    update([formId]);
  }

  Future<void> prepareEdit(CustomerModel customer) async {
    editingCustomer = customer;
    fullNameController.text = customer.fullName;
    emailController.text = customer.email;
    phoneController.text = customer.phoneNumber;
    final cached = minWalletAlertFor(customer);
    minWalletAlertController.text = cached?.toString() ?? '';
    update([formId]);

    try {
      final value = await _repository.fetchMinWalletAlert(customer.email);
      if (editingCustomer?.id != customer.id) return;
      minWalletAlertController.text =
          value == null ? '' : value.toString();
      if (value != null) {
        minWalletAlerts[customer.email.trim().toLowerCase()] = value;
      }
      update([formId]);
    } catch (_) {
      // Keep form usable even if alert fetch fails.
    }
  }

  void preparePhoneCreate() {
    editingPhoneLookup = null;
    lookupPhoneController.clear();
    lookupEmailController.clear();
    update([phoneFormId]);
  }

  void preparePhoneEdit(PhoneLookupModel lookup) {
    editingPhoneLookup = lookup;
    lookupPhoneController.text = lookup.phone;
    lookupEmailController.text = lookup.email;
    update([phoneFormId]);
  }

  Future<bool> submitForm() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (fullName.isEmpty) {
      AppSnackbar.error('الاسم الكامل مطلوب.');
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
      if (editingCustomer != null) {
        await _repository.updateCustomer(
          editingCustomer!.copyWith(
            fullName: fullName,
            email: email,
            phoneNumber: phone,
          ),
          previousPhone: editingCustomer!.phoneNumber,
        );
        AppSnackbar.success('تم تحديث المستخدم وربطه بالهاتف.');
      } else {
        await _repository.createCustomer(
          email: email,
          fullName: fullName,
          phoneNumber: phone,
        );
        AppSnackbar.success('تم إضافة المستخدم وربطه بالهاتف.');
      }
      if (minWalletAlert != null) {
        await _repository.upsertMinWalletAlert(
          userEmail: email,
          value: minWalletAlert,
        );
      }
      await loadAll();
      return true;
    } catch (_) {
      AppSnackbar.error('فشلت العملية. تحقق من الاتصال والصلاحيات.');
      return false;
    } finally {
      isSubmitting = false;
      update([formId]);
    }
  }

  Future<bool> submitPhoneLookup() async {
    final phone = lookupPhoneController.text.trim();
    final email = lookupEmailController.text.trim();

    if (phone.isEmpty) {
      AppSnackbar.error('رقم الهاتف مطلوب.');
      return false;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppSnackbar.error('أدخل بريدًا إلكترونيًا صالحًا.');
      return false;
    }

    isSubmitting = true;
    update([phoneFormId]);

    try {
      final previous = editingPhoneLookup?.phone;
      if (previous != null && previous != phone) {
        await _repository.deletePhoneLookup(previous);
      }
      await _repository.upsertPhoneLookup(phone: phone, email: email);
      AppSnackbar.success('تم حفظ ربط الهاتف.');
      await loadAll();
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر حفظ ربط الهاتف.');
      return false;
    } finally {
      isSubmitting = false;
      update([phoneFormId]);
    }
  }

  Future<void> linkCustomerPhone(CustomerModel customer) async {
    if (customer.phoneNumber.trim().isEmpty || customer.email.trim().isEmpty) {
      AppSnackbar.error('المستخدم بلا هاتف أو بريد.');
      return;
    }
    try {
      await _repository.upsertPhoneLookup(
        phone: customer.phoneNumber,
        email: customer.email,
      );
      AppSnackbar.success('تم ربط الهاتف بالمستخدم.');
      await loadAll();
    } catch (_) {
      AppSnackbar.error('تعذر ربط الهاتف.');
    }
  }

  Future<void> deleteCustomer(CustomerModel customer) async {
    try {
      await _repository.deleteUser(
        customer.id,
        phoneNumber: customer.phoneNumber,
      );
      customers.removeWhere((c) => c.id == customer.id);
      phoneLookups.removeWhere((p) => p.phone == customer.phoneNumber.trim());
      update([listId]);
      AppSnackbar.success('تم حذف المستخدم.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف المستخدم.');
    }
  }

  Future<void> openSendNotification(CustomerModel customer) async {
    final recipientId =
        customer.uid.trim().isNotEmpty ? customer.uid.trim() : customer.id;
    final hasToken = (customer.fcmToken ?? '').trim().isNotEmpty;

    final ok = await Get.dialog<bool>(
      SendNotificationDialog(
        recipientLabel: customer.fullName.isEmpty
            ? customer.email
            : customer.fullName,
        hasFcmToken: hasToken,
        onSend: (title, body) async {
          final result = await _notifications.sendAdminNotification(
            recipientId: recipientId,
            fcmToken: customer.fcmToken,
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

  Future<void> deletePhoneLookup(PhoneLookupModel lookup) async {
    try {
      await _repository.deletePhoneLookup(lookup.phone);
      phoneLookups.removeWhere((p) => p.phone == lookup.phone);
      update([listId]);
      AppSnackbar.success('تم حذف ربط الهاتف.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف ربط الهاتف.');
    }
  }
}
