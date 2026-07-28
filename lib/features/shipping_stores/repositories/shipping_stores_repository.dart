import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/utils/storage_url.dart';
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
