import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/profit_period.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/app_commission_model.dart';
import '../models/app_profit_trans_model.dart';
import '../models/profit_linked_details.dart';
import '../models/shipment_request_money_model.dart';
import '../models/shipment_wallet_model.dart';
import '../models/vendor_money_request_model.dart';
import '../models/vendor_wallet_model.dart';
import '../repositories/commissions_repository.dart';

enum CommissionsTab {
  profits,
  vendorWallet,
  shipmentWallet,
  shipmentMoneyRequests,
  vendorMoneyRequests,
}

class CommissionsController extends GetxController {
  CommissionsController({CommissionsRepository? repository})
      : _repository = repository ?? CommissionsRepository();

  final CommissionsRepository _repository;

  static const String listId = 'commissions_list';
  static const String detailId = 'commissions_detail';
  static const String settingsId = 'commissions_settings';

  final searchController = TextEditingController();
  final appPercentController = TextEditingController();
  final clientStoreAppPercentController = TextEditingController();

  CommissionsTab activeTab = CommissionsTab.profits;
  ProfitPeriod profitPeriod = ProfitPeriod.month;
  ProfitPeriod vendorProfitPeriod = ProfitPeriod.month;
  ProfitPeriod shipmentProfitPeriod = ProfitPeriod.month;

  List<AppProfitTransModel> appProfitTrans = [];
  List<VendorWalletModel> vendorWallet = [];
  List<ShipmentWalletModel> shipmentWallet = [];
  List<ShipmentRequestMoneyModel> shipmentMoneyRequests = [];
  List<VendorMoneyRequestModel> vendorMoneyRequests = [];
  ProfitLinkedDetails? profitLinkedDetails;

  AppProfitTransModel? selectedProfitTrans;
  VendorWalletModel? selectedVendorWallet;
  ShipmentWalletModel? selectedShipmentWallet;
  ShipmentRequestMoneyModel? selectedShipmentMoneyRequest;
  VendorMoneyRequestModel? selectedVendorMoneyRequest;
  AppCommissionModel? appCommissionSettings;
  AppCommissionModel? clientStoreAppCommitionSettings;

  String searchQuery = '';
  String? workerFilter;
  bool isLoading = false;
  bool isLoadingDetail = false;
  bool isLoadingLinkedDetails = false;
  bool isSavingAppPercent = false;
  bool isSavingClientStoreAppPercent = false;
  String? markingVendorSentId;
  String? markingShipmentSentId;
  String? actingShipmentMoneyRequestId;
  String? actingVendorMoneyRequestId;
  String? errorMessage;

  List<VendorMoneyRequestModel> get filteredVendorMoneyRequests {
    final q = searchQuery.trim().toLowerCase();
    final list = [...vendorMoneyRequests];
    list.sort((a, b) {
      final aPending = a.isPending ? 0 : 1;
      final bPending = b.isPending ? 0 : 1;
      if (aPending != bPending) return aPending.compareTo(bPending);
      return (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0));
    });
    if (q.isEmpty) return list;
    return list.where((r) {
      return r.shopName.toLowerCase().contains(q) ||
          r.phone.toLowerCase().contains(q) ||
          r.paymentMethod.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q) ||
          '${r.amount}'.contains(q);
    }).toList();
  }

  List<ShipmentRequestMoneyModel> get filteredShipmentMoneyRequests {
    final q = searchQuery.trim().toLowerCase();
    final list = [...shipmentMoneyRequests];
    list.sort((a, b) {
      // Pending first, then newest.
      final aPending = a.isPending ? 0 : 1;
      final bPending = b.isPending ? 0 : 1;
      if (aPending != bPending) return aPending.compareTo(bPending);
      return (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0));
    });
    if (q.isEmpty) return list;
    return list.where((r) {
      return r.userEmail.toLowerCase().contains(q) ||
          r.userId.toLowerCase().contains(q) ||
          r.phone.toLowerCase().contains(q) ||
          r.paymentMethod.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q) ||
          r.transIds.any((id) => id.toLowerCase().contains(q));
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
    clientStoreAppPercentController.dispose();
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
        _repository.fetchShipmentMoneyRequests(),
        _repository.fetchVendorMoneyRequests(workerId: workerFilter),
        _repository.fetchAppCommissionSettings(),
        _repository.fetchClientStoreAppCommitionSettings(),
      ]);
      appProfitTrans = results[0] as List<AppProfitTransModel>;
      vendorWallet = results[1] as List<VendorWalletModel>;
      shipmentWallet = results[2] as List<ShipmentWalletModel>;
      shipmentMoneyRequests = results[3] as List<ShipmentRequestMoneyModel>;
      vendorMoneyRequests = results[4] as List<VendorMoneyRequestModel>;
      appCommissionSettings = results[5] as AppCommissionModel?;
      clientStoreAppCommitionSettings = results[6] as AppCommissionModel?;
      appPercentController.text =
          (appCommissionSettings?.value ?? 0).toString();
      clientStoreAppPercentController.text =
          (clientStoreAppCommitionSettings?.value ?? 0).toString();

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
      if (selectedShipmentMoneyRequest != null) {
        final still = shipmentMoneyRequests
            .any((r) => r.id == selectedShipmentMoneyRequest!.id);
        if (still) {
          selectedShipmentMoneyRequest = shipmentMoneyRequests.firstWhere(
            (r) => r.id == selectedShipmentMoneyRequest!.id,
          );
        } else {
          clearSelection();
        }
      }
      if (selectedVendorMoneyRequest != null) {
        final still = vendorMoneyRequests
            .any((r) => r.id == selectedVendorMoneyRequest!.id);
        if (still) {
          selectedVendorMoneyRequest = vendorMoneyRequests.firstWhere(
            (r) => r.id == selectedVendorMoneyRequest!.id,
          );
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
    selectedShipmentMoneyRequest = null;
    selectedVendorMoneyRequest = null;
    profitLinkedDetails = null;
    update([listId, detailId]);
    Get.toNamed(AppRoutes.commissionsDetail);
    _loadProfitLinkedDetails(transaction);
  }

  void selectVendorWallet(VendorWalletModel entry) {
    selectedVendorWallet = entry;
    selectedProfitTrans = null;
    selectedShipmentWallet = null;
    selectedShipmentMoneyRequest = null;
    selectedVendorMoneyRequest = null;
    profitLinkedDetails = null;
    update([listId, detailId]);
    Get.toNamed(AppRoutes.commissionsDetail);
  }

  void selectShipmentWallet(ShipmentWalletModel entry) {
    selectedShipmentWallet = entry;
    selectedVendorWallet = null;
    selectedProfitTrans = null;
    selectedShipmentMoneyRequest = null;
    selectedVendorMoneyRequest = null;
    profitLinkedDetails = null;
    update([listId, detailId]);
    Get.toNamed(AppRoutes.commissionsDetail);
  }

  void selectShipmentMoneyRequest(ShipmentRequestMoneyModel request) {
    selectedShipmentMoneyRequest = request;
    selectedVendorWallet = null;
    selectedShipmentWallet = null;
    selectedProfitTrans = null;
    selectedVendorMoneyRequest = null;
    profitLinkedDetails = null;
    update([listId, detailId]);
    Get.toNamed(AppRoutes.commissionsDetail);
  }

  void selectVendorMoneyRequest(VendorMoneyRequestModel request) {
    selectedVendorMoneyRequest = request;
    selectedVendorWallet = null;
    selectedShipmentWallet = null;
    selectedShipmentMoneyRequest = null;
    selectedProfitTrans = null;
    profitLinkedDetails = null;
    update([listId, detailId]);
    Get.toNamed(AppRoutes.commissionsDetail);
  }

  void clearSelection() {
    selectedProfitTrans = null;
    selectedVendorWallet = null;
    selectedShipmentWallet = null;
    selectedShipmentMoneyRequest = null;
    selectedVendorMoneyRequest = null;
    profitLinkedDetails = null;
    isLoadingDetail = false;
    isLoadingLinkedDetails = false;
    update([listId, detailId]);
  }

  Future<void> _loadProfitLinkedDetails(AppProfitTransModel transaction) async {
    isLoadingLinkedDetails = true;
    update([detailId]);
    try {
      profitLinkedDetails = await _repository.fetchProfitLinkedDetails(
        orderId: transaction.orderId,
        paymentTransactionId: transaction.paymentTransactionId,
        shipmentOrderId: transaction.shipmentOrderId,
        shipmentId: transaction.shipmentId,
      );
    } catch (_) {
      profitLinkedDetails = const ProfitLinkedDetails();
    } finally {
      isLoadingLinkedDetails = false;
      update([detailId]);
    }
  }

  Future<void> confirmApproveShipmentMoneyRequest(
    ShipmentRequestMoneyModel request,
  ) async {
    if (!request.isPending || actingShipmentMoneyRequestId != null) return;

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
              Text('تأكيد إرسال الأموال', style: AppTextStyles.h5),
              const SizedBox(height: AppSpacing.md),
              Text(
                'سيتم تحويل حالة الطلب إلى sent وتحديث معاملات shipments_wallet المرتبطة من done إلى sent.',
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
                    Text(
                      'المبلغ: ${request.amount} د.ع',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'معاملات: ${request.transIds.length}',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      request.userEmail.isEmpty
                          ? request.userId
                          : request.userEmail,
                      style: AppTextStyles.caption,
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
    await approveShipmentMoneyRequest(request);
  }

  Future<void> confirmRejectShipmentMoneyRequest(
    ShipmentRequestMoneyModel request,
  ) async {
    if (!request.isPending || actingShipmentMoneyRequestId != null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('رفض طلب السحب', style: AppTextStyles.h5),
        content: Text(
          'هل أنت متأكد من رفض هذا الطلب؟\nالمبلغ: ${request.amount} د.ع',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'رفض',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await rejectShipmentMoneyRequest(request);
  }

  Future<void> approveShipmentMoneyRequest(
    ShipmentRequestMoneyModel request,
  ) async {
    if (!request.isPending) return;

    actingShipmentMoneyRequestId = request.id;
    update([listId, detailId]);

    try {
      await _repository.approveShipmentMoneyRequest(request);
      final updated = request.copyWith(status: 'sent');
      final index =
          shipmentMoneyRequests.indexWhere((r) => r.id == request.id);
      if (index >= 0) shipmentMoneyRequests[index] = updated;
      if (selectedShipmentMoneyRequest?.id == request.id) {
        selectedShipmentMoneyRequest = updated;
      }

      // Refresh local wallet statuses for linked ids.
      for (final id in request.transIds) {
        final wi = shipmentWallet.indexWhere((e) => e.id == id);
        if (wi >= 0 && shipmentWallet[wi].isDone) {
          shipmentWallet[wi] = shipmentWallet[wi].copyWith(status: 'sent');
        }
      }

      AppSnackbar.success('تم إرسال الأموال وتحديث المعاملات');
    } catch (_) {
      AppSnackbar.error('تعذر إرسال طلب الأموال');
    } finally {
      actingShipmentMoneyRequestId = null;
      update([listId, detailId]);
    }
  }

  Future<void> rejectShipmentMoneyRequest(
    ShipmentRequestMoneyModel request,
  ) async {
    if (!request.isPending) return;

    actingShipmentMoneyRequestId = request.id;
    update([listId, detailId]);

    try {
      await _repository.rejectShipmentMoneyRequest(request.id);
      final updated = request.copyWith(status: 'rejected');
      final index =
          shipmentMoneyRequests.indexWhere((r) => r.id == request.id);
      if (index >= 0) shipmentMoneyRequests[index] = updated;
      if (selectedShipmentMoneyRequest?.id == request.id) {
        selectedShipmentMoneyRequest = updated;
      }
      AppSnackbar.success('تم رفض طلب السحب');
    } catch (_) {
      AppSnackbar.error('تعذر رفض طلب السحب');
    } finally {
      actingShipmentMoneyRequestId = null;
      update([listId, detailId]);
    }
  }

  Future<void> confirmApproveVendorMoneyRequest(
    VendorMoneyRequestModel request,
  ) async {
    if (!request.isPending || actingVendorMoneyRequestId != null) return;

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
              Text('تأكيد إرسال أرباح التاجر', style: AppTextStyles.h5),
              const SizedBox(height: AppSpacing.md),
              Text(
                'سيتم تحويل حالة الطلب إلى sent وتحديث معاملات vendors_wallet المرتبطة إلى sent.',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المحل: ${request.shopName.isEmpty ? '—' : request.shopName}',
                      style: AppTextStyles.body2,
                    ),
                    Text(
                      'المبلغ: ${request.amount} د.ع',
                      style: AppTextStyles.h6,
                    ),
                    Text(
                      'معاملات مرتبطة: ${request.vendorsWalletIds.length}',
                      style: AppTextStyles.caption,
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
    await approveVendorMoneyRequest(request);
  }

  Future<void> confirmRejectVendorMoneyRequest(
    VendorMoneyRequestModel request,
  ) async {
    if (!request.isPending || actingVendorMoneyRequestId != null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('رفض طلب السحب', style: AppTextStyles.h5),
        content: Text(
          'هل أنت متأكد من رفض هذا الطلب؟\nالمبلغ: ${request.amount} د.ع',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'رفض',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await rejectVendorMoneyRequest(request);
  }

  Future<void> approveVendorMoneyRequest(
    VendorMoneyRequestModel request,
  ) async {
    if (!request.isPending) return;

    actingVendorMoneyRequestId = request.id;
    update([listId, detailId]);

    try {
      await _repository.approveVendorMoneyRequest(request);
      final updated = request.copyWith(status: 'sent');
      final index =
          vendorMoneyRequests.indexWhere((r) => r.id == request.id);
      if (index >= 0) vendorMoneyRequests[index] = updated;
      if (selectedVendorMoneyRequest?.id == request.id) {
        selectedVendorMoneyRequest = updated;
      }

      for (final id in request.vendorsWalletIds) {
        final wi = vendorWallet.indexWhere((e) => e.id == id);
        if (wi >= 0) {
          vendorWallet[wi] = vendorWallet[wi].copyWith(status: 'sent');
        }
      }

      AppSnackbar.success('تم إرسال الأرباح وتحديث معاملات التاجر');
    } catch (_) {
      AppSnackbar.error('تعذر إرسال طلب سحب التاجر');
    } finally {
      actingVendorMoneyRequestId = null;
      update([listId, detailId]);
    }
  }

  Future<void> rejectVendorMoneyRequest(
    VendorMoneyRequestModel request,
  ) async {
    if (!request.isPending) return;

    actingVendorMoneyRequestId = request.id;
    update([listId, detailId]);

    try {
      await _repository.rejectVendorMoneyRequest(request.id);
      final updated = request.copyWith(status: 'rejected');
      final index =
          vendorMoneyRequests.indexWhere((r) => r.id == request.id);
      if (index >= 0) vendorMoneyRequests[index] = updated;
      if (selectedVendorMoneyRequest?.id == request.id) {
        selectedVendorMoneyRequest = updated;
      }
      AppSnackbar.success('تم رفض طلب السحب');
    } catch (_) {
      AppSnackbar.error('تعذر رفض طلب السحب');
    } finally {
      actingVendorMoneyRequestId = null;
      update([listId, detailId]);
    }
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

  Future<void> saveClientStoreAppCommitionPercent() async {
    final raw = clientStoreAppPercentController.text.trim().replaceAll(',', '.');
    final value = num.tryParse(raw);
    if (value == null || value < 0 || value > 100) {
      AppSnackbar.error('أدخل نسبة صحيحة بين 0 و 100');
      return;
    }

    isSavingClientStoreAppPercent = true;
    update([settingsId]);

    try {
      clientStoreAppCommitionSettings =
          await _repository.saveClientStoreAppCommitionValue(value);
      clientStoreAppPercentController.text = value.toString();
      AppSnackbar.success('تم تحديث نسبة التطبيق لسوق القطع المستعملة');
    } catch (_) {
      AppSnackbar.error('تعذر حفظ نسبة التطبيق لسوق القطع المستعملة');
    } finally {
      isSavingClientStoreAppPercent = false;
      update([settingsId]);
    }
  }
}
