import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/banner_model.dart';
import '../repositories/banners_repository.dart';

class BannersController extends GetxController {
  BannersController({BannersRepository? repository})
      : _repository = repository ?? BannersRepository();

  final BannersRepository _repository;

  static const String listId = 'banners_list';
  static const String formId = 'banners_form';

  final TextEditingController orderController = TextEditingController();

  List<BannerModel> banners = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  BannerModel? editingBanner;
  Uint8List? selectedImageBytes;
  String? selectedImageName;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
  }

  @override
  void onClose() {
    orderController.dispose();
    super.onClose();
  }

  Future<void> loadBanners() async {
    isLoading = true;
    errorMessage = null;
    update([listId]);

    try {
      banners = await _repository.fetchBanners();
    } catch (_) {
      errorMessage = 'تعذر تحميل البنرات. حاول مرة أخرى.';
    } finally {
      isLoading = false;
      update([listId]);
    }
  }

  void prepareCreate() {
    editingBanner = null;
    selectedImageBytes = null;
    selectedImageName = null;
    final nextOrder = banners.isEmpty
        ? 1
        : banners.map((b) => b.order).reduce((a, b) => a > b ? a : b) + 1;
    orderController.text = '$nextOrder';
    update([formId]);
  }

  void prepareEdit(BannerModel banner) {
    editingBanner = banner;
    selectedImageBytes = null;
    selectedImageName = null;
    orderController.text = '${banner.order}';
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
    final order = int.tryParse(orderController.text.trim());
    if (order == null || order < 0) {
      AppSnackbar.error('أدخل رقم ترتيب صالح.');
      return false;
    }

    final isEdit = editingBanner != null;
    if (!isEdit && selectedImageBytes == null) {
      AppSnackbar.error('يجب اختيار صورة للبنر.');
      return false;
    }

    isSubmitting = true;
    update([formId]);

    try {
      if (isEdit) {
        await _repository.updateBanner(
          banner: editingBanner!,
          imageBytes: selectedImageBytes,
          order: order,
        );
        AppSnackbar.success('تم تحديث البنر بنجاح.');
      } else {
        await _repository.createBanner(
          imageBytes: selectedImageBytes!,
          order: order,
        );
        AppSnackbar.success('تم إضافة البنر بنجاح.');
      }

      await loadBanners();
      return true;
    } catch (_) {
      AppSnackbar.error('فشلت العملية. تحقق من الاتصال والصلاحيات.');
      return false;
    } finally {
      isSubmitting = false;
      update([formId]);
    }
  }

  Future<void> deleteBanner(BannerModel banner) async {
    try {
      await _repository.deleteBanner(banner);
      banners.removeWhere((b) => b.id == banner.id);
      update([listId]);
      AppSnackbar.success('تم حذف البنر.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف البنر.');
    }
  }
}
