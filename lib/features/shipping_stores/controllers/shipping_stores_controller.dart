import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/notifications_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/feedback/send_notification_dialog.dart';
import '../models/delivery_fee_model.dart';
import '../models/shippiment_store_model.dart';
import '../repositories/shipping_stores_repository.dart';

class ShippingStoresController extends GetxController {
  ShippingStoresController({
    ShippingStoresRepository? repository,
    NotificationsService? notificationsService,
  })  : _repository = repository ?? ShippingStoresRepository(),
        _notifications = notificationsService ?? NotificationsService();

  final ShippingStoresRepository _repository;
  final NotificationsService _notifications;

  static const String listId = 'shipping_stores_list';
  static const String formId = 'shipping_stores_form';
  static const String deliveryFeeId = 'shipping_delivery_fee';
  static const String financeFormId = 'shipping_finance_form';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final profileIdController = TextEditingController();
  final rateController = TextEditingController();
  final minWalletAlertController = TextEditingController();
  final financeAmountController = TextEditingController();
  final financeMinAlertController = TextEditingController();
  final inCityFeeController = TextEditingController();
  final outCityFeeController = TextEditingController();
  final searchController = TextEditingController();

  List<ShippimentStoreModel> stores = [];
  Map<String, num> walletBalances = {};
  Map<String, num> minWalletAlerts = {};
  DeliveryFeeModel? deliveryFee;
  String searchQuery = '';
  String vehicleSizeType = 'large';
  bool isLoading = false;
  bool isSubmitting = false;
  bool isSavingDeliveryFee = false;
  bool isAdjustingFinance = false;
  String? errorMessage;
  ShippimentStoreModel? editingStore;
  ShippimentStoreModel? financeStore;
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

  num walletAmountFor(ShippimentStoreModel store) =>
      walletBalances[store.id] ?? 0;

  num? minWalletAlertFor(ShippimentStoreModel store) =>
      minWalletAlerts[store.id];

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    profileIdController.dispose();
    rateController.dispose();
    minWalletAlertController.dispose();
    financeAmountController.dispose();
    financeMinAlertController.dispose();
    inCityFeeController.dispose();
    outCityFeeController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadStores() async {
    isLoading = true;
    errorMessage = null;
    update([listId, deliveryFeeId]);

    try {
      final results = await Future.wait([
        _repository.fetchStores(),
        _repository.fetchDeliveryFee(),
        _repository.fetchShipmentWalletBalances(),
        _repository.fetchAllShipmentMinWalletAlerts(),
      ]);
      stores = results[0] as List<ShippimentStoreModel>;
      deliveryFee = results[1] as DeliveryFeeModel?;
      walletBalances = results[2] as Map<String, num>;
      minWalletAlerts = results[3] as Map<String, num>;
      inCityFeeController.text = deliveryFee?.inCity.toString() ?? '';
      outCityFeeController.text = deliveryFee?.outCity.toString() ?? '';
    } catch (_) {
      errorMessage = 'تعذر تحميل متاجر الشحن. حاول مرة أخرى.';
    } finally {
      isLoading = false;
      update([listId, deliveryFeeId]);
    }
  }

  void prepareFinance(ShippimentStoreModel store) {
    financeStore = store;
    financeAmountController.clear();
    final alert = minWalletAlertFor(store);
    financeMinAlertController.text = alert?.toString() ?? '';
    update([financeFormId]);
  }

  bool isFinanceNegativeRestricted(ShippimentStoreModel store) {
    final alert = minWalletAlertFor(store);
    return alert != null && alert == 0;
  }

  Future<void> setFinanceNegativeRestricted(bool restricted) async {
    final store = financeStore;
    if (store == null) return;

    final value = restricted ? 0 : 50000;
    isAdjustingFinance = true;
    update([financeFormId]);

    try {
      await _repository.upsertShipmentMinWalletAlert(
        userId: store.id,
        email: store.email,
        value: value,
      );
      minWalletAlerts[store.id] = value;
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

  Future<bool> adjustShipmentWallet({required bool isAdd}) async {
    final store = financeStore;
    if (store == null) return false;

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
      await _repository.adjustShipmentWalletBalance(
        companyId: store.id,
        companyName: store.name,
        delta: delta,
      );
      walletBalances[store.id] = (walletBalances[store.id] ?? 0) + delta;
      AppSnackbar.success(
        isAdd
            ? 'تم إضافة المبلغ إلى محفظة شركة الشحن.'
            : 'تم خصم المبلغ من محفظة شركة الشحن.',
      );
      update([listId, financeFormId]);
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر تعديل محفظة شركة الشحن.');
      return false;
    } finally {
      isAdjustingFinance = false;
      update([financeFormId]);
    }
  }

  Future<bool> saveFinanceMinAlert() async {
    final store = financeStore;
    if (store == null) return false;

    final raw = financeMinAlertController.text.trim().replaceAll(',', '.');
    final value = num.tryParse(raw);
    if (value == null || value < 0) {
      AppSnackbar.error('أدخل حدًا أقصى صالحًا.');
      return false;
    }

    isAdjustingFinance = true;
    update([financeFormId]);

    try {
      await _repository.upsertShipmentMinWalletAlert(
        userId: store.id,
        email: store.email,
        value: value,
      );
      minWalletAlerts[store.id] = value;
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

  Future<void> saveDeliveryFee() async {
    final inRaw = inCityFeeController.text.trim().replaceAll(',', '.');
    final outRaw = outCityFeeController.text.trim().replaceAll(',', '.');
    final inCity = num.tryParse(inRaw);
    final outCity = num.tryParse(outRaw);

    if (inCity == null || inCity < 0) {
      AppSnackbar.error('أدخل رسوم داخل المدينة بشكل صحيح.');
      return;
    }
    if (outCity == null || outCity < 0) {
      AppSnackbar.error('أدخل رسوم خارج المدينة بشكل صحيح.');
      return;
    }

    isSavingDeliveryFee = true;
    update([deliveryFeeId]);

    try {
      deliveryFee = await _repository.saveDeliveryFee(
        inCity: inCity,
        outCity: outCity,
      );
      inCityFeeController.text = deliveryFee!.inCity.toString();
      outCityFeeController.text = deliveryFee!.outCity.toString();
      AppSnackbar.success('تم حفظ رسوم التوصيل.');
    } catch (_) {
      AppSnackbar.error('تعذر حفظ رسوم التوصيل.');
    } finally {
      isSavingDeliveryFee = false;
      update([deliveryFeeId]);
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
    minWalletAlertController.clear();
    update([formId]);
  }

  Future<void> prepareEdit(ShippimentStoreModel store) async {
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
    minWalletAlertController.clear();
    update([formId]);

    try {
      final value = await _repository.fetchShipmentMinWalletAlert(
        userId: store.id,
        email: store.email,
      );
      if (editingStore?.id != store.id) return;
      minWalletAlertController.text =
          value == null ? '' : value.toString();
      update([formId]);
    } catch (_) {
      // Keep form usable even if alert fetch fails.
    }
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
      late final ShippimentStoreModel savedStore;
      if (editingStore != null) {
        savedStore = await _repository.updateStore(
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
        savedStore = await _repository.createStore(
          name: name,
          email: email,
          profileId: profileId,
          rate: rate,
          vehicleSizeType: vehicleSizeType,
          imageBytes: selectedImageBytes,
        );
        AppSnackbar.success('تم إضافة متجر الشحن بنجاح.');
      }
      if (minWalletAlert != null) {
        await _repository.upsertShipmentMinWalletAlert(
          userId: savedStore.id,
          email: email,
          value: minWalletAlert,
        );
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

  Future<void> openSendNotification(ShippimentStoreModel store) async {
    final hasToken = (store.fcmToken ?? '').trim().isNotEmpty;

    final ok = await Get.dialog<bool>(
      SendNotificationDialog(
        recipientLabel: store.name.isEmpty ? store.email : store.name,
        hasFcmToken: hasToken,
        onSend: (title, body) async {
          final result = await _notifications.sendAdminNotification(
            recipientId: store.id,
            fcmToken: store.fcmToken,
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

  String _generateProfileId() {
    final random = Random();
    final number = 1000000000 + random.nextInt(900000000);
    return 'CMP-$number';
  }
}
