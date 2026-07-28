import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../models/app_commission_model.dart';
import '../models/incentive_request_model.dart';
import '../models/provider_commission_model.dart';

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
