import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/status_label_utils.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../commissions/models/provider_commission_model.dart';
import '../../shipping_stores/models/shippiment_store_model.dart';
import '../models/accepted_offer_model.dart';
import '../models/offer_model.dart';
import '../models/request_model.dart';
import '../models/sale_part_model.dart';
import '../models/shipment_offer_model.dart';
import '../repositories/requests_repository.dart';

enum RequestsSourceTab { requests, saleParts }

class RequestsController extends GetxController {
  RequestsController({RequestsRepository? repository})
      : _repository = repository ?? RequestsRepository();

  final RequestsRepository _repository;

  static const String listId = 'requests_list';
  static const String detailId = 'requests_detail';

  final searchController = TextEditingController();

  RequestsSourceTab sourceTab = RequestsSourceTab.requests;
  List<RequestModel> requests = [];
  List<SalePartModel> saleParts = [];
  List<OfferModel> selectedOffers = [];
  List<AcceptedOfferModel> selectedAcceptedOffers = [];
  List<ShipmentOfferModel> selectedShipmentOffers = [];
  List<ProviderCommissionModel> selectedCommissions = [];
  Map<String, ShippimentStoreModel> storesById = {};
  RequestModel? selectedRequest;
  SalePartModel? selectedSalePart;

  String searchQuery = '';
  String statusFilter = 'all';
  String? pendingRequestId;
  String? pendingOfferId;
  bool isLoading = false;
  bool isLoadingRelations = false;
  String? errorMessage;
  String? relationsError;

  List<String> get availableStatuses {
    final set = <String>{};
    if (sourceTab == RequestsSourceTab.saleParts) {
      for (final p in saleParts) {
        if (p.status.isNotEmpty) {
          set.add(StatusLabelUtils.canonicalizeForFilter(p.status));
        }
      }
    } else {
      for (final r in requests) {
        if (r.status.isNotEmpty) {
          set.add(StatusLabelUtils.canonicalizeForFilter(r.status));
        }
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  List<RequestModel> get filteredRequests {
    return requests.where((r) {
      if (!StatusLabelUtils.matchesFilter(r.status, statusFilter)) return false;
      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return r.partName.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.carBrand.toLowerCase().contains(q) ||
          r.userAddress.toLowerCase().contains(q) ||
          r.vin.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList();
  }

  List<SalePartModel> get filteredSaleParts {
    return saleParts.where((p) {
      if (!StatusLabelUtils.matchesFilter(p.status, statusFilter)) return false;
      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.partName.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.carBrand.toLowerCase().contains(q) ||
          p.sellerName.toLowerCase().contains(q) ||
          p.sellerAddress.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
    }).toList();
  }

  OfferModel? offerById(String offerId) {
    if (offerId.isEmpty) return null;
    for (final offer in selectedOffers) {
      if (offer.id == offerId) return offer;
    }
    return null;
  }

  ShippimentStoreModel? storeById(String storeId) => storesById[storeId];

  int shipmentCountForOffer(String offerId) {
    return selectedShipmentOffers.where((s) => s.offerId == offerId).length;
  }

  bool isOfferAcceptedRecord(String offerId) {
    return selectedAcceptedOffers.any(
      (a) => a.offerId == offerId || a.id == offerId,
    );
  }

  bool hasCommissionForOffer(String offerId) {
    return selectedCommissions.any((c) => c.offerId == offerId);
  }

  @override
  void onInit() {
    super.onInit();
    applyRouteArguments(reload: false);
    loadRequests();
  }

  void applyRouteArguments({bool reload = true}) {
    final args = Get.arguments;
    if (args is Map) {
      if (args['requestId'] is String) {
        pendingRequestId = (args['requestId'] as String).trim();
        sourceTab = RequestsSourceTab.requests;
      }
      if (args['offerId'] is String) {
        pendingOfferId = (args['offerId'] as String).trim();
      }
    }

    if (reload && requests.isNotEmpty) {
      selectPendingRequest();
    }
  }

  Future<void> selectPendingRequest() async {
    final id = pendingRequestId;
    if (id == null || id.isEmpty) return;

    final matches = requests.where((r) => r.id == id);
    if (matches.isEmpty) return;

    sourceTab = RequestsSourceTab.requests;
    await selectRequest(matches.first);
    pendingRequestId = null;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadRequests() async {
    isLoading = true;
    errorMessage = null;
    update([listId, detailId]);

    try {
      final results = await Future.wait([
        _repository.fetchRequests(),
        _repository.fetchSaleParts(),
      ]);
      requests = results[0] as List<RequestModel>;
      saleParts = results[1] as List<SalePartModel>;

      if (pendingRequestId != null && pendingRequestId!.isNotEmpty) {
        await selectPendingRequest();
      } else if (selectedRequest != null) {
        final stillExists =
            requests.any((r) => r.id == selectedRequest!.id);
        if (stillExists) {
          selectedRequest =
              requests.firstWhere((r) => r.id == selectedRequest!.id);
          await _loadRelations(selectedRequest!.id);
        } else {
          clearSelection();
        }
      } else if (selectedSalePart != null) {
        final still =
            saleParts.any((p) => p.id == selectedSalePart!.id);
        if (still) {
          selectedSalePart =
              saleParts.firstWhere((p) => p.id == selectedSalePart!.id);
        } else {
          clearSelection();
        }
      }
    } catch (_) {
      errorMessage = 'تعذر تحميل الطلبات. حاول مرة أخرى.';
    } finally {
      isLoading = false;
      update([listId, detailId]);
    }
  }

  void setSourceTab(RequestsSourceTab tab) {
    if (sourceTab == tab) return;
    sourceTab = tab;
    statusFilter = 'all';
    clearSelection();
    update([listId, detailId]);
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    update([listId]);
  }

  void setStatusFilter(String status) {
    statusFilter = status == 'all'
        ? 'all'
        : StatusLabelUtils.canonicalizeForFilter(status);
    update([listId]);
  }

  Future<void> selectRequest(RequestModel request) async {
    selectedRequest = request;
    selectedSalePart = null;
    selectedOffers = [];
    selectedAcceptedOffers = [];
    selectedShipmentOffers = [];
    selectedCommissions = [];
    storesById = {};
    relationsError = null;
    update([listId, detailId]);
    await _loadRelations(request.id);
  }

  void selectSalePart(SalePartModel part) {
    selectedSalePart = part;
    selectedRequest = null;
    selectedOffers = [];
    selectedAcceptedOffers = [];
    selectedShipmentOffers = [];
    selectedCommissions = [];
    storesById = {};
    relationsError = null;
    isLoadingRelations = false;
    update([listId, detailId]);
  }

  void clearSelection() {
    selectedRequest = null;
    selectedSalePart = null;
    selectedOffers = [];
    selectedAcceptedOffers = [];
    selectedShipmentOffers = [];
    selectedCommissions = [];
    storesById = {};
    relationsError = null;
    isLoadingRelations = false;
    update([listId, detailId]);
  }

  Future<void> confirmDeleteSelectedRequest() async {
    final request = selectedRequest;
    if (request == null) return;
    final confirmed = await _showDangerousDeleteDialog(
      title: 'حذف طلب',
      itemLabel: request.partName.isEmpty ? 'هذا الطلب' : request.partName,
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteRequest(request.id);
      requests.removeWhere((r) => r.id == request.id);
      clearSelection();
      update([listId, detailId]);
      AppSnackbar.success('تم حذف الطلب.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف الطلب.');
    }
  }

  Future<void> confirmDeleteSelectedSalePart() async {
    final part = selectedSalePart;
    if (part == null) return;
    final confirmed = await _showDangerousDeleteDialog(
      title: 'حذف قطعة للبيع',
      itemLabel: part.partName.isEmpty ? 'هذه القطعة' : part.partName,
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteSalePart(part.id);
      saleParts.removeWhere((p) => p.id == part.id);
      clearSelection();
      update([listId, detailId]);
      AppSnackbar.success('تم حذف القطعة.');
    } catch (_) {
      AppSnackbar.error('تعذر حذف القطعة.');
    }
  }

  Future<bool?> _showDangerousDeleteDialog({
    required String title,
    required String itemLabel,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title, style: AppTextStyles.h5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'هل تريد حذف "$itemLabel"؟',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'تحذير مهم: لا يتم الحذف إلا لبيانات تجريبية أو طلب خاطئ فقط. '
                'أي حذف لبيانات حقيقية قد يسبب خطرًا على النظام وارتباطات الطلبات والعروض.',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
              'نعم، احذف',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _loadRelations(String requestId) async {
    isLoadingRelations = true;
    relationsError = null;
    update([detailId]);

    try {
      final results = await Future.wait([
        _repository.fetchOffersForRequest(requestId),
        _repository.fetchAcceptedOffersForRequest(requestId),
        _repository.fetchShipmentOffersForRequest(requestId),
        _repository.fetchCommissionsForRequest(requestId),
      ]);

      selectedOffers = results[0] as List<OfferModel>;
      selectedAcceptedOffers = results[1] as List<AcceptedOfferModel>;
      selectedShipmentOffers = results[2] as List<ShipmentOfferModel>;
      selectedCommissions = results[3] as List<ProviderCommissionModel>;

      storesById = await _repository.fetchStoresByIds(
        selectedShipmentOffers.map((s) => s.uid),
      );
    } catch (_) {
      relationsError =
          'تعذر تحميل العروض والقبول والشحن والعمولات المرتبطة.';
      selectedOffers = [];
      selectedAcceptedOffers = [];
      selectedShipmentOffers = [];
      selectedCommissions = [];
      storesById = {};
    } finally {
      isLoadingRelations = false;
      update([detailId]);
    }
  }
}
