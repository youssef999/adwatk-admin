import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/user_roles.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../users/repositories/users_repository.dart';
import '../models/vendor_model.dart';

class VendorsController extends GetxController {
  VendorsController({UsersRepository? repository})
      : _repository = repository ?? UsersRepository();

  final UsersRepository _repository;

  static const String listId = 'vendors_list';
  static const String formId = 'vendors_form';

  final shopNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final specializationsController = TextEditingController();
  final searchController = TextEditingController();

  List<VendorModel> vendors = [];
  String searchQuery = '';
  String selectedRole = UserRoles.worker;
  String? focusedVendorId;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  VendorModel? editingVendor;

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

  @override
  void onClose() {
    shopNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    latController.dispose();
    lngController.dispose();
    specializationsController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadVendors() async {
    isLoading = true;
    errorMessage = null;
    update([listId]);

    try {
      vendors = await _repository.fetchVendors();
    } catch (_) {
      errorMessage = 'تعذر تحميل البائعين. حاول مرة أخرى.';
    } finally {
      isLoading = false;
      update([listId]);
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
    update([formId]);
  }

  void prepareEdit(VendorModel vendor) {
    editingVendor = vendor;
    selectedRole = vendor.role;
    shopNameController.text = vendor.shopName;
    emailController.text = vendor.email;
    phoneController.text = vendor.phoneNumber;
    addressController.text = vendor.address;
    latController.text = vendor.shopLat.toString();
    lngController.text = vendor.shopLng.toString();
    specializationsController.text = vendor.specializations.join(', ');
    update([formId]);
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

    isSubmitting = true;
    update([formId]);

    try {
      if (editingVendor != null) {
        await _repository.updateVendor(
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
        await _repository.createVendor(
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
}
