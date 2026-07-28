import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/shippiment_store_model.dart';
import '../repositories/shipping_stores_repository.dart';

class ShippingStoresController extends GetxController {
  ShippingStoresController({ShippingStoresRepository? repository})
      : _repository = repository ?? ShippingStoresRepository();

  final ShippingStoresRepository _repository;

  static const String listId = 'shipping_stores_list';
  static const String formId = 'shipping_stores_form';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final profileIdController = TextEditingController();
  final rateController = TextEditingController();
  final searchController = TextEditingController();

  List<ShippimentStoreModel> stores = [];
  String searchQuery = '';
  String vehicleSizeType = 'large';
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  ShippimentStoreModel? editingStore;
  Uint8List? selectedImageBytes;
  String? selectedImageName;

  List<ShippimentStoreModel> get filteredStores {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return stores;
    return stores.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.profileId.toLowerCase().contains(q) ||
          s.vehicleSizeType.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadStores();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    profileIdController.dispose();
    rateController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadStores() async {
    isLoading = true;
    errorMessage = null;
    update([listId]);

    try {
      stores = await _repository.fetchStores();
    } catch (_) {
      errorMessage = 'تعذر تحميل متاجر الشحن. حاول مرة أخرى.';
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
    editingStore = null;
    selectedImageBytes = null;
    selectedImageName = null;
    vehicleSizeType = 'large';
    nameController.clear();
    emailController.clear();
    profileIdController.text = _generateProfileId();
    rateController.text = '0';
    update([formId]);
  }

  void prepareEdit(ShippimentStoreModel store) {
    editingStore = store;
    selectedImageBytes = null;
    selectedImageName = null;
    vehicleSizeType = store.vehicleSizeType.isEmpty
        ? 'large'
        : store.vehicleSizeType;
    nameController.text = store.name;
    emailController.text = store.email;
    profileIdController.text = store.profileId;
    rateController.text = store.rate.toString();
    update([formId]);
  }

  void setVehicleSizeType(String value) {
    vehicleSizeType = value;
    update([formId]);
  }

  Future<void> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      AppSnackbar.error('تعذر قراءة ملف الصورة.');
      return;
    }
    selectedImageBytes = file.bytes;
    selectedImageName = file.name;
    update([formId]);
  }

  void clearSelectedImage() {
    selectedImageBytes = null;
    selectedImageName = null;
    update([formId]);
  }

  Future<bool> submitForm() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final profileId = profileIdController.text.trim();
    final rate = num.tryParse(rateController.text.trim());

    if (name.isEmpty) {
      AppSnackbar.error('اسم المتجر مطلوب.');
      return false;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppSnackbar.error('أدخل بريدًا إلكترونيًا صالحًا.');
      return false;
    }
    if (profileId.isEmpty) {
      AppSnackbar.error('معرّف الملف مطلوب.');
      return false;
    }
    if (rate == null || rate < 0) {
      AppSnackbar.error('أدخل تقييمًا صالحًا.');
      return false;
    }

    isSubmitting = true;
    update([formId]);

    try {
      if (editingStore != null) {
        await _repository.updateStore(
          store: editingStore!,
          name: name,
          email: email,
          profileId: profileId,
          rate: rate,
          vehicleSizeType: vehicleSizeType,
          imageBytes: selectedImageBytes,
        );
        AppSnackbar.success('تم تحديث متجر الشحن بنجاح.');
      } else {
        await _repository.createStore(
          name: name,
          email: email,
          profileId: profileId,
          rate: rate,
          vehicleSizeType: vehicleSizeType,
          imageBytes: selectedImageBytes,
        );
        AppSnackbar.success('تم إضافة متجر الشحن بنجاح.');
      }
      await loadStores();
      return true;
    } catch (_) {
      AppSnackbar.error('فشلت العملية. تحقق من الاتصال والصلاحيات.');
      return false;
    } finally {
      isSubmitting = false;
      update([formId]);
    }
  }

  Future<void> deleteStore(ShippimentStoreModel store) async {
    try {
      await _repository.deleteStore(store);
      stores.removeWhere((s) => s.id == store.id);
      update([listId]);
      AppSnackbar.success('تم حذف متجر الشحن.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف متجر الشحن.');
    }
  }

  String _generateProfileId() {
    final random = Random();
    final number = 1000000000 + random.nextInt(900000000);
    return 'CMP-$number';
  }
}
