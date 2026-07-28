import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/customer_model.dart';
import '../models/phone_lookup_model.dart';
import '../repositories/users_repository.dart';

enum UsersPageTab { customers, phoneLinks }

class UsersController extends GetxController {
  UsersController({UsersRepository? repository})
      : _repository = repository ?? UsersRepository();

  final UsersRepository _repository;

  static const String listId = 'users_list';
  static const String formId = 'users_form';
  static const String phoneFormId = 'phone_form';

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final searchController = TextEditingController();
  final lookupPhoneController = TextEditingController();
  final lookupEmailController = TextEditingController();

  UsersPageTab activeTab = UsersPageTab.customers;
  List<CustomerModel> customers = [];
  List<PhoneLookupModel> phoneLookups = [];
  String searchQuery = '';
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  CustomerModel? editingCustomer;
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
      ]);
      customers = results[0] as List<CustomerModel>;
      phoneLookups = results[1] as List<PhoneLookupModel>;
    } catch (_) {
      errorMessage = 'تعذر تحميل المستخدمين. حاول مرة أخرى.';
    } finally {
      isLoading = false;
      update([listId]);
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
    update([formId]);
  }

  void prepareEdit(CustomerModel customer) {
    editingCustomer = customer;
    fullNameController.text = customer.fullName;
    emailController.text = customer.email;
    phoneController.text = customer.phoneNumber;
    update([formId]);
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
