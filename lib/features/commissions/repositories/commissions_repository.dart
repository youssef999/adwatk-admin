import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../models/app_commission_model.dart';
import '../models/app_profit_trans_model.dart';
import '../models/incentive_request_model.dart';
import '../models/provider_commission_model.dart';
import '../models/shipment_wallet_model.dart';
import '../models/vendor_wallet_model.dart';

class CommissionsRepository {
  CommissionsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _providerCommissions =>
      _firestore.collection(FirestoreCollections.providerCommission);

  CollectionReference<Map<String, dynamic>> get _incentiveRequests =>
      _firestore.collection(FirestoreCollections.incentiveRequests);

  CollectionReference<Map<String, dynamic>> get _appCommission =>
      _firestore.collection(FirestoreCollections.appCommission);

  CollectionReference<Map<String, dynamic>> get _appProfitsTrans =>
      _firestore.collection(FirestoreCollections.appProfitsTrans);

  CollectionReference<Map<String, dynamic>> get _vendorsWallet =>
      _firestore.collection(FirestoreCollections.vendorsWallet);

  CollectionReference<Map<String, dynamic>> get _shipmentsWallet =>
      _firestore.collection(FirestoreCollections.shipmentsWallet);

  Future<List<ProviderCommissionModel>> fetchProviderCommissions({
    String? workerId,
    String? requestId,
  }) async {
    Query<Map<String, dynamic>> query = _providerCommissions;

    if (workerId != null && workerId.isNotEmpty) {
      query = query.where('workerId', isEqualTo: workerId);
    } else if (requestId != null && requestId.isNotEmpty) {
      query = query.where('requestId', isEqualTo: requestId);
    }

    try {
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(ProviderCommissionModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await query.get();
        final list =
            snapshot.docs.map(ProviderCommissionModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<IncentiveRequestModel>> fetchIncentiveRequests({
    String? workerId,
  }) async {
    Query<Map<String, dynamic>> query = _incentiveRequests;

    if (workerId != null && workerId.isNotEmpty) {
      query = query.where('workerId', isEqualTo: workerId);
    }

    try {
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(IncentiveRequestModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await query.get();
        final list =
            snapshot.docs.map(IncentiveRequestModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<ProviderCommissionModel>> fetchCommissionsByIds(
    List<String> ids,
  ) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return [];

    final result = <ProviderCommissionModel>[];
    for (var i = 0; i < unique.length; i += 30) {
      final chunk = unique.sublist(
        i,
        i + 30 > unique.length ? unique.length : i + 30,
      );
      final snapshot = await _providerCommissions
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      result.addAll(snapshot.docs.map(ProviderCommissionModel.fromFirestore));
    }

    result.sort((a, b) => (b.createdAt ?? DateTime(0))
        .compareTo(a.createdAt ?? DateTime(0)));
    return result;
  }

  /// Loads all vendor wallet rows. Totals must sum `status == done` only.
  Future<List<VendorWalletModel>> fetchVendorWalletEntries({
    String? vendorId,
  }) async {
    Query<Map<String, dynamic>> query = _vendorsWallet;

    if (vendorId != null && vendorId.isNotEmpty) {
      query = query.where('vendor_id', isEqualTo: vendorId);
    }

    try {
      final snapshot =
          await query.orderBy('created_at', descending: true).get();
      return snapshot.docs.map(VendorWalletModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await query.get();
        final list =
            snapshot.docs.map(VendorWalletModel.fromFirestore).toList();
        list.sort(
          (a, b) => (b.effectiveAt ?? DateTime(0))
              .compareTo(a.effectiveAt ?? DateTime(0)),
        );
        return list;
      }
      rethrow;
    }
  }

  Future<void> markVendorWalletAsSent(String id) async {
    await _vendorsWallet.doc(id).update({'status': 'sent'});
  }

  /// Loads all shipping wallet rows. Totals must sum `status == done` only.
  Future<List<ShipmentWalletModel>> fetchShipmentWalletEntries({
    String? shipmentCompanyId,
  }) async {
    Query<Map<String, dynamic>> query = _shipmentsWallet;

    if (shipmentCompanyId != null && shipmentCompanyId.isNotEmpty) {
      query =
          query.where('shipment_company_id', isEqualTo: shipmentCompanyId);
    }

    try {
      final snapshot =
          await query.orderBy('created_at', descending: true).get();
      return snapshot.docs.map(ShipmentWalletModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await query.get();
        final list =
            snapshot.docs.map(ShipmentWalletModel.fromFirestore).toList();
        list.sort(
          (a, b) => (b.effectiveAt ?? DateTime(0))
              .compareTo(a.effectiveAt ?? DateTime(0)),
        );
        return list;
      }
      rethrow;
    }
  }

  Future<void> markShipmentWalletAsSent(String id) async {
    await _shipmentsWallet.doc(id).update({'status': 'sent'});
  }

  /// Loads all app profit ledger rows. Totals must sum `status == done` only.
  Future<List<AppProfitTransModel>> fetchAppProfitTransactions() async {
    Query<Map<String, dynamic>> query = _appProfitsTrans;

    try {
      final snapshot =
          await query.orderBy('created_at', descending: true).get();
      return snapshot.docs.map(AppProfitTransModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await query.get();
        final list =
            snapshot.docs.map(AppProfitTransModel.fromFirestore).toList();
        list.sort(
          (a, b) => (b.effectiveAt ?? DateTime(0))
              .compareTo(a.effectiveAt ?? DateTime(0)),
        );
        return list;
      }
      rethrow;
    }
  }

  /// Loads the active app commission settings document (first doc in collection).
  Future<AppCommissionModel?> fetchAppCommissionSettings() async {
    final snapshot = await _appCommission.limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return AppCommissionModel.fromFirestore(snapshot.docs.first);
  }

  Future<AppCommissionModel> saveAppCommissionValue(num value) async {
    final existing = await fetchAppCommissionSettings();
    if (existing != null) {
      await _appCommission.doc(existing.id).update({'value': value});
      return existing.copyWith(value: value);
    }

    final doc = await _appCommission.add({'value': value});
    return AppCommissionModel(id: doc.id, value: value);
  }
}
