import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../requests/models/accepted_offer_model.dart';
import '../../requests/models/shipment_offer_model.dart';
import '../../shipping_stores/models/shippiment_store_model.dart';
import '../models/app_commission_model.dart';
import '../models/app_profit_trans_model.dart';
import '../models/payment_transaction_model.dart';
import '../models/profit_linked_details.dart';
import '../models/provider_commission_model.dart';
import '../models/shipment_request_money_model.dart';
import '../models/shipment_wallet_model.dart';
import '../models/vendor_money_request_model.dart';
import '../models/vendor_wallet_model.dart';

class CommissionsRepository {
  CommissionsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _providerCommissions =>
      _firestore.collection(FirestoreCollections.providerCommission);

  CollectionReference<Map<String, dynamic>> get _moneyRequests =>
      _firestore.collection(FirestoreCollections.moneyRequests);

  CollectionReference<Map<String, dynamic>> get _appCommission =>
      _firestore.collection(FirestoreCollections.appCommission);
  CollectionReference<Map<String, dynamic>> get _clientStoreAppCommition =>
      _firestore.collection(FirestoreCollections.clientStoreAppCommition);

  CollectionReference<Map<String, dynamic>> get _appProfitsTrans =>
      _firestore.collection(FirestoreCollections.appProfitsTrans);

  CollectionReference<Map<String, dynamic>> get _vendorsWallet =>
      _firestore.collection(FirestoreCollections.vendorsWallet);

  CollectionReference<Map<String, dynamic>> get _shipmentsWallet =>
      _firestore.collection(FirestoreCollections.shipmentsWallet);

  CollectionReference<Map<String, dynamic>> get _shipmentRequestMoney =>
      _firestore.collection(FirestoreCollections.shipmentRequestMoney);

  CollectionReference<Map<String, dynamic>> get _acceptedOffers =>
      _firestore.collection(FirestoreCollections.acceptedOffers);

  CollectionReference<Map<String, dynamic>> get _paymentTransactions =>
      _firestore.collection(FirestoreCollections.paymentTransactions);

  CollectionReference<Map<String, dynamic>> get _shipmentOffers =>
      _firestore.collection(FirestoreCollections.shipmentOffers);

  CollectionReference<Map<String, dynamic>> get _shippimentStores =>
      _firestore.collection(FirestoreCollections.shippimentStores);

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

  Future<List<VendorMoneyRequestModel>> fetchVendorMoneyRequests({
    String? workerId,
  }) async {
    Query<Map<String, dynamic>> query = _moneyRequests;

    if (workerId != null && workerId.isNotEmpty) {
      query = query.where('workerId', isEqualTo: workerId);
    }

    try {
      final snapshot =
          await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(VendorMoneyRequestModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await query.get();
        final list =
            snapshot.docs.map(VendorMoneyRequestModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  /// Approves vendor withdrawal: request → `sent`, and every linked
  /// `vendors_wallet` doc in `vendors_wallet_ids` → `sent`.
  Future<void> approveVendorMoneyRequest(
    VendorMoneyRequestModel request,
  ) async {
    final batch = _firestore.batch();
    batch.update(_moneyRequests.doc(request.id), {'status': 'sent'});

    for (final id in request.vendorsWalletIds) {
      batch.update(_vendorsWallet.doc(id), {'status': 'sent'});
    }

    await batch.commit();
  }

  Future<void> rejectVendorMoneyRequest(String id) async {
    await _moneyRequests.doc(id).update({'status': 'rejected'});
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

  Future<List<ShipmentRequestMoneyModel>> fetchShipmentMoneyRequests() async {
    Query<Map<String, dynamic>> query = _shipmentRequestMoney;

    try {
      final snapshot =
          await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(ShipmentRequestMoneyModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await query.get();
        final list =
            snapshot.docs.map(ShipmentRequestMoneyModel.fromFirestore).toList();
        list.sort(
          (a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)),
        );
        return list;
      }
      rethrow;
    }
  }

  /// Approves a money request: sets request to `sent` and marks linked
  /// `shipments_wallet` docs (`trans_ids`) from `done` → `sent`.
  Future<void> approveShipmentMoneyRequest(
    ShipmentRequestMoneyModel request,
  ) async {
    final batch = _firestore.batch();
    batch.update(_shipmentRequestMoney.doc(request.id), {'status': 'sent'});

    for (final id in request.transIds) {
      final ref = _shipmentsWallet.doc(id);
      final snap = await ref.get();
      if (!snap.exists) continue;
      final status = (snap.data()?['status'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (status == 'done') {
        batch.update(ref, {'status': 'sent'});
      }
    }

    await batch.commit();
  }

  Future<void> rejectShipmentMoneyRequest(String id) async {
    await _shipmentRequestMoney.doc(id).update({'status': 'rejected'});
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

  /// Loads app cut for used-parts market (client_store_app_commition).
  Future<AppCommissionModel?> fetchClientStoreAppCommitionSettings() async {
    final snapshot = await _clientStoreAppCommition.limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return AppCommissionModel.fromFirestore(snapshot.docs.first);
  }

  Future<AppCommissionModel> saveClientStoreAppCommitionValue(num value) async {
    final existing = await fetchClientStoreAppCommitionSettings();
    if (existing != null) {
      await _clientStoreAppCommition.doc(existing.id).update({'value': value});
      return existing.copyWith(value: value);
    }
    final doc = await _clientStoreAppCommition.add({'value': value});
    return AppCommissionModel(id: doc.id, value: value);
  }

  Future<ProfitLinkedDetails> fetchProfitLinkedDetails({
    String? orderId,
    String? paymentTransactionId,
    String? shipmentOrderId,
    String? shipmentId,
  }) async {
    final futures = <Future<void>>[];
    AcceptedOfferModel? order;
    PaymentTransactionModel? payment;
    ShipmentOfferModel? shipmentOffer;
    ShippimentStoreModel? shipmentCompany;

    final oid = orderId?.trim() ?? '';
    if (oid.isNotEmpty) {
      futures.add(() async {
        final doc = await _acceptedOffers.doc(oid).get();
        if (doc.exists) order = AcceptedOfferModel.fromFirestore(doc);
      }());
    }

    final pid = paymentTransactionId?.trim() ?? '';
    if (pid.isNotEmpty) {
      futures.add(() async {
        final doc = await _paymentTransactions.doc(pid).get();
        if (doc.exists) {
          payment = PaymentTransactionModel.fromFirestore(doc);
        }
      }());
    }

    final soid = shipmentOrderId?.trim() ?? '';
    if (soid.isNotEmpty) {
      futures.add(() async {
        final doc = await _shipmentOffers.doc(soid).get();
        if (doc.exists) {
          shipmentOffer = ShipmentOfferModel.fromFirestore(doc);
        }
      }());
    }

    final sid = shipmentId?.trim() ?? '';
    if (sid.isNotEmpty) {
      futures.add(() async {
        final doc = await _shippimentStores.doc(sid).get();
        if (doc.exists) {
          shipmentCompany = ShippimentStoreModel.fromFirestore(doc);
        }
      }());
    }

    await Future.wait(futures);
    return ProfitLinkedDetails(
      order: order,
      payment: payment,
      shipmentOffer: shipmentOffer,
      shipmentCompany: shipmentCompany,
    );
  }
}
