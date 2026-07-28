import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/profit_period.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/app_commission_model.dart';
import '../models/incentive_request_model.dart';
import '../models/provider_commission_model.dart';
import '../repositories/commissions_repository.dart';

enum CommissionsTab { profits, providerCommissions, incentives }

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

  List<ProviderCommissionModel> commissions = [];
  List<IncentiveRequestModel> incentives = [];
  List<ProviderCommissionModel> incentiveLinkedCommissions = [];

  ProviderCommissionModel? selectedCommission;
  IncentiveRequestModel? selectedIncentive;
  AppCommissionModel? appCommissionSettings;

  String searchQuery = '';
  String? workerFilter;
  bool isLoading = false;
  bool isLoadingDetail = false;
  bool isSavingAppPercent = false;
  String? errorMessage;

  List<ProviderCommissionModel> get filteredCommissions {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return commissions;
    return commissions.where((c) {
      return c.shopName.toLowerCase().contains(q) ||
          c.workerId.toLowerCase().contains(q) ||
          c.requestId.toLowerCase().contains(q) ||
          c.offerId.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q);
    }).toList();
  }

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

  /// Transactions in the selected profit period (optionally narrowed by search).
  List<ProviderCommissionModel> get profitTransactions {
    final start = profitPeriod.startOf(DateTime.now());
    final inPeriod = commissions.where((c) {
      final created = c.createdAt;
      if (created == null) return false;
      return !created.isBefore(start);
    });

    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return inPeriod.toList();
    return inPeriod.where((c) {
      return c.shopName.toLowerCase().contains(q) ||
          c.workerId.toLowerCase().contains(q) ||
          c.requestId.toLowerCase().contains(q) ||
          c.offerId.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q);
    }).toList();
  }

  num get totalAppProfit =>
      profitTransactions.fold<num>(0, (sum, c) => sum + c.appCommission);

  num get totalSalesInPeriod =>
      profitTransactions.fold<num>(0, (sum, c) => sum + c.price);

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
        _repository.fetchProviderCommissions(workerId: workerFilter),
        _repository.fetchIncentiveRequests(workerId: workerFilter),
        _repository.fetchAppCommissionSettings(),
      ]);
      commissions = results[0] as List<ProviderCommissionModel>;
      incentives = results[1] as List<IncentiveRequestModel>;
      appCommissionSettings = results[2] as AppCommissionModel?;
      appPercentController.text =
          (appCommissionSettings?.value ?? 0).toString();

      if (selectedCommission != null) {
        final still =
            commissions.any((c) => c.id == selectedCommission!.id);
        if (still) {
          selectedCommission =
              commissions.firstWhere((c) => c.id == selectedCommission!.id);
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

  void onSearchChanged(String value) {
    searchQuery = value;
    update([listId]);
  }

  void clearWorkerFilter() {
    workerFilter = null;
    loadAll();
  }

  void selectCommission(ProviderCommissionModel commission) {
    selectedCommission = commission;
    selectedIncentive = null;
    incentiveLinkedCommissions = [];
    update([listId, detailId]);
  }

  Future<void> selectIncentive(IncentiveRequestModel incentive) async {
    selectedIncentive = incentive;
    selectedCommission = null;
    update([listId, detailId]);
    await _loadIncentiveLinks(incentive);
  }

  void clearSelection() {
    selectedCommission = null;
    selectedIncentive = null;
    incentiveLinkedCommissions = [];
    isLoadingDetail = false;
    update([listId, detailId]);
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
