import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/profit_period.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/app_commission_model.dart';
import '../models/app_profit_trans_model.dart';
import '../models/incentive_request_model.dart';
import '../models/provider_commission_model.dart';
import '../models/shipment_wallet_model.dart';
import '../models/vendor_wallet_model.dart';
import '../repositories/commissions_repository.dart';

enum CommissionsTab { profits, vendorWallet, shipmentWallet, incentives }

class CommissionsController extends GetxController {
  CommissionsController({CommissionsRepository? repository})
      : _repository = repository ?? CommissionsRepository();

  final CommissionsRepository _repository;

  static const String listId = 'commissions_list';
  static const String detailId = 'commissions_detail';
  static const String settingsId = 'commissions_settings';

  final searchController = TextEditingController();
  final appPercentController = TextEditingController();

  CommissionsTab activeTab = CommissionsTab.profits;
  ProfitPeriod profitPeriod = ProfitPeriod.month;
  ProfitPeriod vendorProfitPeriod = ProfitPeriod.month;
  ProfitPeriod shipmentProfitPeriod = ProfitPeriod.month;

  List<AppProfitTransModel> appProfitTrans = [];
  List<VendorWalletModel> vendorWallet = [];
  List<ShipmentWalletModel> shipmentWallet = [];
  List<IncentiveRequestModel> incentives = [];
  List<ProviderCommissionModel> incentiveLinkedCommissions = [];

  AppProfitTransModel? selectedProfitTrans;
  VendorWalletModel? selectedVendorWallet;
  ShipmentWalletModel? selectedShipmentWallet;
  IncentiveRequestModel? selectedIncentive;
  AppCommissionModel? appCommissionSettings;

  String searchQuery = '';
  String? workerFilter;
  bool isLoading = false;
  bool isLoadingDetail = false;
  bool isSavingAppPercent = false;
  String? markingVendorSentId;
  String? markingShipmentSentId;
  String? errorMessage;

  List<IncentiveRequestModel> get filteredIncentives {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return incentives;
    return incentives.where((i) {
      return i.shopName.toLowerCase().contains(q) ||
          i.workerId.toLowerCase().contains(q) ||
          i.status.toLowerCase().contains(q) ||
          i.id.toLowerCase().contains(q);
    }).toList();
  }

  /// All vendor wallet rows in period (any status), action-needed first.
  List<VendorWalletModel> get filteredVendorWallet {
    final start = vendorProfitPeriod.startOf(DateTime.now());
    var inPeriod = vendorWallet.where((e) {
      final at = e.effectiveAt;
      if (at == null) return false;
      return !at.isBefore(start);
    }).toList();

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      inPeriod = inPeriod.where((e) {
        return e.productName.toLowerCase().contains(q) ||
            e.customerName.toLowerCase().contains(q) ||
            e.vendorId.toLowerCase().contains(q) ||
            e.requestId.toLowerCase().contains(q) ||
            e.orderId.toLowerCase().contains(q) ||
            e.status.toLowerCase().contains(q) ||
            e.id.toLowerCase().contains(q);
      }).toList();
    }

    inPeriod.sort((a, b) {
      final byStatus = a.listPriority.compareTo(b.listPriority);
      if (byStatus != 0) return byStatus;
      return (b.effectiveAt ?? DateTime(0))
          .compareTo(a.effectiveAt ?? DateTime(0));
    });
    return inPeriod;
  }

  /// Only `done` counts toward vendor profit total.
  List<VendorWalletModel> get doneVendorWalletEntries =>
      filteredVendorWallet.where((e) => e.isDone).toList();

  List<VendorWalletModel> get requestSentVendorWalletEntries =>
      filteredVendorWallet.where((e) => e.isRequestSent).toList();

  num get totalVendorProfit =>
      doneVendorWalletEntries.fold<num>(0, (sum, e) => sum + e.amount);

  /// All shipment wallet rows in period (any status), organized by status.
  List<ShipmentWalletModel> get filteredShipmentWallet {
    final start = shipmentProfitPeriod.startOf(DateTime.now());
    var inPeriod = shipmentWallet.where((e) {
      final at = e.effectiveAt;
      if (at == null) return false;
      return !at.isBefore(start);
    }).toList();

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      inPeriod = inPeriod.where((e) {
        return e.shipmentCompanyName.toLowerCase().contains(q) ||
            e.productName.toLowerCase().contains(q) ||
            e.customerName.toLowerCase().contains(q) ||
            e.shipmentCompanyId.toLowerCase().contains(q) ||
            e.requestId.toLowerCase().contains(q) ||
            e.orderId.toLowerCase().contains(q) ||
            e.status.toLowerCase().contains(q) ||
            e.id.toLowerCase().contains(q);
      }).toList();
    }

    inPeriod.sort((a, b) {
      final byStatus = a.listPriority.compareTo(b.listPriority);
      if (byStatus != 0) return byStatus;
      return (b.effectiveAt ?? DateTime(0))
          .compareTo(a.effectiveAt ?? DateTime(0));
    });
    return inPeriod;
  }

  /// Only `done` counts toward shipment wallet total.
  List<ShipmentWalletModel> get doneShipmentWalletEntries =>
      filteredShipmentWallet.where((e) => e.isDone).toList();

  List<ShipmentWalletModel> get pendingShipmentWalletEntries =>
      filteredShipmentWallet.where((e) => e.isPending).toList();

  num get totalShipmentWallet =>
      doneShipmentWalletEntries.fold<num>(0, (sum, e) => sum + e.amount);

  /// All app profit txs in period (any status) for the list.
  List<AppProfitTransModel> get profitTransactions {
    final start = profitPeriod.startOf(DateTime.now());
    final inPeriod = appProfitTrans.where((t) {
      final at = t.effectiveAt;
      if (at == null) return false;
      return !at.isBefore(start);
    });

    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return inPeriod.toList();
    return inPeriod.where((t) {
      return t.requestId.toLowerCase().contains(q) ||
          t.orderId.toLowerCase().contains(q) ||
          t.paymentTransactionId.toLowerCase().contains(q) ||
          t.shipmentId.toLowerCase().contains(q) ||
          t.shipmentOrderId.toLowerCase().contains(q) ||
          t.paymentType.toLowerCase().contains(q) ||
          t.status.toLowerCase().contains(q) ||
          t.id.toLowerCase().contains(q);
    }).toList();
  }

  /// Only `done` rows count toward app profit total.
  List<AppProfitTransModel> get doneProfitTransactions =>
      profitTransactions.where((t) => t.isDone).toList();

  num get totalAppProfit =>
      doneProfitTransactions.fold<num>(0, (sum, t) => sum + t.amount);

  @override
  void onInit() {
    super.onInit();
    applyRouteArguments(reload: false);
    loadAll();
  }

  void applyRouteArguments({bool reload = true}) {
    final args = Get.arguments;
    final newFilter = (args is Map && args['workerId'] is String)
        ? args['workerId'] as String
        : null;
    if (newFilter == workerFilter) return;
    workerFilter = newFilter;
    if (reload) loadAll();
  }

  @override
  void onClose() {
    searchController.dispose();
    appPercentController.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    update([listId, detailId, settingsId]);

    try {
      final results = await Future.wait([
        _repository.fetchAppProfitTransactions(),
        _repository.fetchVendorWalletEntries(vendorId: workerFilter),
        _repository.fetchShipmentWalletEntries(),
        _repository.fetchIncentiveRequests(workerId: workerFilter),
        _repository.fetchAppCommissionSettings(),
      ]);
      appProfitTrans = results[0] as List<AppProfitTransModel>;
      vendorWallet = results[1] as List<VendorWalletModel>;
      shipmentWallet = results[2] as List<ShipmentWalletModel>;
      incentives = results[3] as List<IncentiveRequestModel>;
      appCommissionSettings = results[4] as AppCommissionModel?;
      appPercentController.text =
          (appCommissionSettings?.value ?? 0).toString();

      if (selectedProfitTrans != null) {
        final still =
            appProfitTrans.any((t) => t.id == selectedProfitTrans!.id);
        if (still) {
          selectedProfitTrans =
              appProfitTrans.firstWhere((t) => t.id == selectedProfitTrans!.id);
        } else {
          clearSelection();
        }
      }
      if (selectedVendorWallet != null) {
        final still =
            vendorWallet.any((e) => e.id == selectedVendorWallet!.id);
        if (still) {
          selectedVendorWallet =
              vendorWallet.firstWhere((e) => e.id == selectedVendorWallet!.id);
        } else {
          clearSelection();
        }
      }
      if (selectedShipmentWallet != null) {
        final still =
            shipmentWallet.any((e) => e.id == selectedShipmentWallet!.id);
        if (still) {
          selectedShipmentWallet = shipmentWallet
              .firstWhere((e) => e.id == selectedShipmentWallet!.id);
        } else {
          clearSelection();
        }
      }
      if (selectedIncentive != null) {
        final still = incentives.any((i) => i.id == selectedIncentive!.id);
        if (still) {
          selectedIncentive =
              incentives.firstWhere((i) => i.id == selectedIncentive!.id);
          await _loadIncentiveLinks(selectedIncentive!);
        } else {
          clearSelection();
        }
      }
    } catch (_) {
      errorMessage = 'تعذر تحميل العمولات والحوافز.';
    } finally {
      isLoading = false;
      update([listId, detailId, settingsId]);
    }
  }

  void setTab(CommissionsTab tab) {
    if (activeTab == tab) return;
    activeTab = tab;
    clearSelection();
    update([listId, detailId]);
  }

  void setProfitPeriod(ProfitPeriod period) {
    if (profitPeriod == period) return;
    profitPeriod = period;
    update([listId]);
  }

  void setVendorProfitPeriod(ProfitPeriod period) {
    if (vendorProfitPeriod == period) return;
    vendorProfitPeriod = period;
    update([listId]);
  }

  void setShipmentProfitPeriod(ProfitPeriod period) {
    if (shipmentProfitPeriod == period) return;
    shipmentProfitPeriod = period;
    update([listId]);
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    update([listId]);
  }

  void clearWorkerFilter() {
    workerFilter = null;
    loadAll();
  }

  void selectProfitTrans(AppProfitTransModel transaction) {
    selectedProfitTrans = transaction;
    selectedVendorWallet = null;
    selectedShipmentWallet = null;
    selectedIncentive = null;
    incentiveLinkedCommissions = [];
    update([listId, detailId]);
  }

  void selectVendorWallet(VendorWalletModel entry) {
    selectedVendorWallet = entry;
    selectedProfitTrans = null;
    selectedShipmentWallet = null;
    selectedIncentive = null;
    incentiveLinkedCommissions = [];
    update([listId, detailId]);
  }

  void selectShipmentWallet(ShipmentWalletModel entry) {
    selectedShipmentWallet = entry;
    selectedVendorWallet = null;
    selectedProfitTrans = null;
    selectedIncentive = null;
    incentiveLinkedCommissions = [];
    update([listId, detailId]);
  }

  Future<void> selectIncentive(IncentiveRequestModel incentive) async {
    selectedIncentive = incentive;
    selectedVendorWallet = null;
    selectedShipmentWallet = null;
    selectedProfitTrans = null;
    update([listId, detailId]);
    await _loadIncentiveLinks(incentive);
  }

  void clearSelection() {
    selectedProfitTrans = null;
    selectedVendorWallet = null;
    selectedShipmentWallet = null;
    selectedIncentive = null;
    incentiveLinkedCommissions = [];
    isLoadingDetail = false;
    update([listId, detailId]);
  }

  Future<void> confirmMarkVendorWalletSent(VendorWalletModel entry) async {
    if (!entry.canMarkAsSent || markingVendorSentId != null) return;

    final currency = entry.currency.isEmpty ? 'د.ع' : entry.currency;
    final product = entry.productName.isEmpty ? 'معاملة أرباح' : entry.productName;
    final fromStatus = entry.status.trim().toLowerCase();

    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.send_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'إرسال الأرباح للتاجر',
                      style: AppTextStyles.h5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'هل أنت متأكد من تحويل الحالة من $fromStatus إلى sent؟',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product, style: AppTextStyles.h6),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'المبلغ: ${entry.amount} $currency',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (entry.vendorId.trim().isNotEmpty)
                      Text(
                        'التاجر: ${entry.vendorId}',
                        style: AppTextStyles.caption,
                      ),
                    Text(
                      '$fromStatus → sent',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'تأكيد الإرسال',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    await markVendorWalletAsSent(entry);
  }

  Future<void> markVendorWalletAsSent(VendorWalletModel entry) async {
    if (!entry.canMarkAsSent) return;

    markingVendorSentId = entry.id;
    update([listId, detailId]);

    try {
      await _repository.markVendorWalletAsSent(entry.id);
      final updated = entry.copyWith(status: 'sent');
      final index = vendorWallet.indexWhere((e) => e.id == entry.id);
      if (index >= 0) vendorWallet[index] = updated;
      if (selectedVendorWallet?.id == entry.id) {
        selectedVendorWallet = updated;
      }
      AppSnackbar.success('تم تحديث الحالة إلى sent');
    } catch (_) {
      AppSnackbar.error('تعذر تحديث حالة إرسال الأرباح');
    } finally {
      markingVendorSentId = null;
      update([listId, detailId]);
    }
  }

  Future<void> confirmMarkShipmentWalletSent(
    ShipmentWalletModel entry,
  ) async {
    if (!entry.isDone || markingShipmentSentId != null) return;

    final company = entry.shipmentCompanyName.isEmpty
        ? 'شركة الشحن'
        : entry.shipmentCompanyName;
    final currency = entry.currency.isEmpty ? 'د.ع' : entry.currency;

    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'تأكيد تحويل الحالة',
                      style: AppTextStyles.h5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'هل أنت متأكد من تحويل هذه المعاملة من done إلى sent؟',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company, style: AppTextStyles.h6),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'المبلغ: ${entry.amount} $currency',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: entry.amount < 0
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                    if (entry.productName.trim().isNotEmpty)
                      Text(
                        'المنتج: ${entry.productName}',
                        style: AppTextStyles.caption,
                      ),
                    Text(
                      'done → sent',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: AppColors.surface,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'تأكيد الإرسال',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    await markShipmentWalletAsSent(entry);
  }

  Future<void> markShipmentWalletAsSent(ShipmentWalletModel entry) async {
    if (!entry.isDone) return;

    markingShipmentSentId = entry.id;
    update([listId, detailId]);

    try {
      await _repository.markShipmentWalletAsSent(entry.id);
      final updated = entry.copyWith(status: 'sent');
      final index = shipmentWallet.indexWhere((e) => e.id == entry.id);
      if (index >= 0) shipmentWallet[index] = updated;
      if (selectedShipmentWallet?.id == entry.id) {
        selectedShipmentWallet = updated;
      }
      AppSnackbar.success('تم تحويل الحالة إلى sent');
    } catch (_) {
      AppSnackbar.error('تعذر تحديث حالة معاملة الشحن');
    } finally {
      markingShipmentSentId = null;
      update([listId, detailId]);
    }
  }

  Future<void> saveAppCommissionPercent() async {
    final raw = appPercentController.text.trim().replaceAll(',', '.');
    final value = num.tryParse(raw);
    if (value == null || value < 0 || value > 100) {
      AppSnackbar.error('أدخل نسبة صحيحة بين 0 و 100');
      return;
    }

    isSavingAppPercent = true;
    update([settingsId]);

    try {
      appCommissionSettings =
          await _repository.saveAppCommissionValue(value);
      appPercentController.text = value.toString();
      AppSnackbar.success('تم تحديث نسبة عمولة التطبيق');
    } catch (_) {
      AppSnackbar.error('تعذر حفظ نسبة عمولة التطبيق');
    } finally {
      isSavingAppPercent = false;
      update([settingsId]);
    }
  }

  Future<void> _loadIncentiveLinks(IncentiveRequestModel incentive) async {
    isLoadingDetail = true;
    update([detailId]);
    try {
      incentiveLinkedCommissions =
          await _repository.fetchCommissionsByIds(incentive.commissionDocIds);
    } catch (_) {
      incentiveLinkedCommissions = [];
    } finally {
      isLoadingDetail = false;
      update([detailId]);
    }
  }
}
