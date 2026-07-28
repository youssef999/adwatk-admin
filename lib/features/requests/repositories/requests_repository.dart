import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../commissions/models/provider_commission_model.dart';
import '../../shipping_stores/models/shippiment_store_model.dart';
import '../models/accepted_offer_model.dart';
import '../models/offer_model.dart';
import '../models/request_model.dart';
import '../models/sale_part_model.dart';
import '../models/shipment_offer_model.dart';

class RequestsRepository {
  RequestsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(FirestoreCollections.requests);

  CollectionReference<Map<String, dynamic>> get _offers =>
      _firestore.collection(FirestoreCollections.offers);

  CollectionReference<Map<String, dynamic>> get _acceptedOffers =>
      _firestore.collection(FirestoreCollections.acceptedOffers);

  CollectionReference<Map<String, dynamic>> get _shipmentOffers =>
      _firestore.collection(FirestoreCollections.shipmentOffers);

  CollectionReference<Map<String, dynamic>> get _shippimentStores =>
      _firestore.collection(FirestoreCollections.shippimentStores);

  CollectionReference<Map<String, dynamic>> get _providerCommissions =>
      _firestore.collection(FirestoreCollections.providerCommission);

  CollectionReference<Map<String, dynamic>> get _saleParts =>
      _firestore.collection(FirestoreCollections.saleParts);

  Future<List<RequestModel>> fetchRequests() async {
    try {
      final snapshot =
          await _requests.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(RequestModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _requests.get();
        final list = snapshot.docs.map(RequestModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<SalePartModel>> fetchSaleParts() async {
    try {
      final snapshot =
          await _saleParts.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(SalePartModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _saleParts.get();
        final list = snapshot.docs.map(SalePartModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<OfferModel>> fetchOffersForRequest(String requestId) async {
    try {
      final snapshot = await _offers
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(OfferModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot =
            await _offers.where('requestId', isEqualTo: requestId).get();
        final list = snapshot.docs.map(OfferModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<AcceptedOfferModel>> fetchAcceptedOffersForRequest(
    String requestId,
  ) async {
    try {
      final snapshot = await _acceptedOffers
          .where('requestId', isEqualTo: requestId)
          .orderBy('acceptedAt', descending: true)
          .get();
      return snapshot.docs.map(AcceptedOfferModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _acceptedOffers
            .where('requestId', isEqualTo: requestId)
            .get();
        final list =
            snapshot.docs.map(AcceptedOfferModel.fromFirestore).toList();
        list.sort((a, b) => (b.acceptedAt ?? DateTime(0))
            .compareTo(a.acceptedAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<ShipmentOfferModel>> fetchShipmentOffersForRequest(
    String requestId,
  ) async {
    try {
      final snapshot = await _shipmentOffers
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(ShipmentOfferModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _shipmentOffers
            .where('requestId', isEqualTo: requestId)
            .get();
        final list =
            snapshot.docs.map(ShipmentOfferModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<ProviderCommissionModel>> fetchCommissionsForRequest(
    String requestId,
  ) async {
    try {
      final snapshot = await _providerCommissions
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(ProviderCommissionModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _providerCommissions
            .where('requestId', isEqualTo: requestId)
            .get();
        final list =
            snapshot.docs.map(ProviderCommissionModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<Map<String, ShippimentStoreModel>> fetchStoresByIds(
    Iterable<String> ids,
  ) async {
    final uniqueIds = ids.where((id) => id.isNotEmpty).toSet();
    if (uniqueIds.isEmpty) return {};

    final result = <String, ShippimentStoreModel>{};
    // Firestore whereIn supports max 30 values per query.
    final idList = uniqueIds.toList();
    for (var i = 0; i < idList.length; i += 30) {
      final chunk = idList.sublist(
        i,
        i + 30 > idList.length ? idList.length : i + 30,
      );
      final snapshot = await _shippimentStores
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snapshot.docs) {
        result[doc.id] = ShippimentStoreModel.fromFirestore(doc);
      }
    }
    return result;
  }
}
