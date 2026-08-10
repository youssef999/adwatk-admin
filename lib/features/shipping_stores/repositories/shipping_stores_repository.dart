import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/utils/storage_url.dart';
import '../models/delivery_fee_model.dart';
import '../models/shippiment_store_model.dart';

class ShippingStoresRepository {
  ShippingStoresRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.shippimentStores);

  CollectionReference<Map<String, dynamic>> get _shipmentMinWalletAlert =>
      _firestore.collection(FirestoreCollections.shipmentMinWalletAlert);

  CollectionReference<Map<String, dynamic>> get _deliveryFee =>
      _firestore.collection(FirestoreCollections.deliveryFee);

  CollectionReference<Map<String, dynamic>> get _shipmentsWallet =>
      _firestore.collection(FirestoreCollections.shipmentsWallet);

  /// Sum of `shipments_wallet.amount` where `status == done`, keyed by company id.
  Future<Map<String, num>> fetchShipmentWalletBalances() async {
    final snapshot = await _shipmentsWallet.get();
    final totals = <String, num>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = (data['status'] as String?)?.trim().toLowerCase() ?? '';
      if (status != 'done') continue;
      final companyId =
          (data['shipment_company_id'] as String?)?.trim() ?? '';
      if (companyId.isEmpty) continue;
      totals[companyId] =
          (totals[companyId] ?? 0) + (data['amount'] as num? ?? 0);
    }
    return totals;
  }

  Future<void> adjustShipmentWalletBalance({
    required String companyId,
    required String companyName,
    required num delta,
  }) async {
    final id = companyId.trim();
    if (id.isEmpty || delta == 0) return;
    final amount = delta % 1 == 0 ? delta.toInt() : delta;
    await _shipmentsWallet.add({
      'amount': amount,
      'status': 'done',
      'shipment_company_id': id,
      'shipment_company_name': companyName.trim(),
      'currency': 'IQD',
      'product_name': 'تعديل إداري',
      'customer_name': 'admin',
      'customer_id': '',
      'order_id': '',
      'request_id': '',
      'payment_type': 'admin_adjustment',
      'payment_transaction_id': '',
      'product_id': '',
      'shipment_offer_id': '',
      'vendor_id': '',
      'created_at': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Maps `user_id` → alert value from `shipment_min_wallet_alert`.
  Future<Map<String, num>> fetchAllShipmentMinWalletAlerts() async {
    final snapshot = await _shipmentMinWalletAlert.get();
    final byId = <String, num>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final value = _parseNumericValue(data['value']);
      if (value == null) continue;
      final userId = (data['user_id'] as String?)?.trim() ?? '';
      if (userId.isNotEmpty) byId[userId] = value;
    }
    return byId;
  }

  Future<DeliveryFeeModel?> fetchDeliveryFee() async {
    final doc =
        await _deliveryFee.doc(DeliveryFeeModel.documentId).get();
    if (!doc.exists) return null;
    return DeliveryFeeModel.fromFirestore(doc);
  }

  Future<DeliveryFeeModel> saveDeliveryFee({
    required num inCity,
    required num outCity,
  }) async {
    final model = DeliveryFeeModel(
      id: DeliveryFeeModel.documentId,
      inCity: inCity,
      outCity: outCity,
    );
    await _deliveryFee.doc(model.id).set(
          model.toFirestore(),
          SetOptions(merge: true),
        );
    return model;
  }

  num? _parseNumericValue(dynamic raw) {
    if (raw is num) return raw;
    if (raw is String) return num.tryParse(raw.replaceAll(',', '.'));
    return null;
  }

  Future<num?> fetchShipmentMinWalletAlert({
    required String userId,
    String? email,
  }) async {
    final id = userId.trim();
    if (id.isNotEmpty) {
      final byId = await _shipmentMinWalletAlert
          .where('user_id', isEqualTo: id)
          .limit(1)
          .get();
      if (byId.docs.isNotEmpty) {
        return _parseNumericValue(byId.docs.first.data()['value']);
      }
    }

    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isEmpty) return null;
    final byEmail = await _shipmentMinWalletAlert
        .where('email', isEqualTo: trimmedEmail)
        .limit(1)
        .get();
    if (byEmail.docs.isEmpty) return null;
    return _parseNumericValue(byEmail.docs.first.data()['value']);
  }

  Future<void> upsertShipmentMinWalletAlert({
    required String userId,
    required String email,
    required num value,
  }) async {
    final id = userId.trim();
    final trimmedEmail = email.trim();
    if (id.isEmpty || trimmedEmail.isEmpty) return;

    final storedValue = value % 1 == 0 ? value.toInt() : value;
    final payload = <String, dynamic>{
      'email': trimmedEmail,
      'user_id': id,
      'value': storedValue,
    };

    final byId = await _shipmentMinWalletAlert
        .where('user_id', isEqualTo: id)
        .limit(1)
        .get();
    if (byId.docs.isNotEmpty) {
      await byId.docs.first.reference.update(payload);
      return;
    }

    final byEmail = await _shipmentMinWalletAlert
        .where('email', isEqualTo: trimmedEmail)
        .limit(1)
        .get();
    if (byEmail.docs.isNotEmpty) {
      await byEmail.docs.first.reference.update(payload);
      return;
    }

    await _shipmentMinWalletAlert.add({
      ...payload,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ShippimentStoreModel>> fetchStores() async {
    try {
      final snapshot =
          await _collection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map(ShippimentStoreModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _collection.get();
        final list =
            snapshot.docs.map(ShippimentStoreModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<ShippimentStoreModel> createStore({
    required String name,
    required String email,
    required String profileId,
    required num rate,
    required String vehicleSizeType,
    Uint8List? imageBytes,
  }) async {
    final docRef = _collection.doc();
    var imageUrl = '';
    if (imageBytes != null) {
      imageUrl = await _uploadProfileImage(docRef.id, imageBytes);
    }

    final store = ShippimentStoreModel(
      id: docRef.id,
      name: name,
      email: email,
      profileId: profileId,
      profileImageUrl: imageUrl,
      rate: rate,
      vehicleSizeType: vehicleSizeType,
    );

    await docRef.set(
      store.toCreateFirestore(includeImageTimestamps: imageUrl.isNotEmpty),
    );
    return store;
  }

  Future<ShippimentStoreModel> updateStore({
    required ShippimentStoreModel store,
    required String name,
    required String email,
    required String profileId,
    required num rate,
    required String vehicleSizeType,
    Uint8List? imageBytes,
  }) async {
    var imageUrl = store.profileImageUrl;
    var imageChanged = false;

    if (imageBytes != null) {
      await _deleteStorageFileIfOwned(store.profileImageUrl);
      imageUrl = await _uploadProfileImage(store.id, imageBytes);
      imageChanged = true;
    }

    final updated = store.copyWith(
      name: name,
      email: email,
      profileId: profileId,
      profileImageUrl: imageUrl,
      rate: rate,
      vehicleSizeType: vehicleSizeType,
    );

    await _collection.doc(store.id).update(
          updated.toUpdateFirestore(imageChanged: imageChanged),
        );
    return updated;
  }

  Future<void> deleteStore(ShippimentStoreModel store) async {
    await _collection.doc(store.id).delete();
    await _deleteStorageFileIfOwned(store.profileImageUrl);
  }

  Future<String> _uploadProfileImage(String storeId, Uint8List bytes) async {
    final compressed = await ImageCompressor.compress(
      bytes,
      maxWidth: 800,
      quality: 80,
    );
    final ref = _storage.ref().child('shippiment_stores').child(storeId);
    await ref.putData(
      compressed,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=31536000',
      ),
    );
    return ref.getDownloadURL();
  }

  Future<void> _deleteStorageFileIfOwned(String imageUrl) async {
    if (!StorageUrl.isFirebaseStorage(imageUrl)) return;
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {}
  }
}
