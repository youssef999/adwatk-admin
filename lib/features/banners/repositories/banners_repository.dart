import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/utils/storage_url.dart';
import '../models/banner_model.dart';

class BannersRepository {
  BannersRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.banners);

  Future<List<BannerModel>> fetchBanners() async {
    final snapshot = await _collection.orderBy('order').get();
    return snapshot.docs.map(BannerModel.fromFirestore).toList();
  }

  Future<BannerModel> createBanner({
    required Uint8List imageBytes,
    required int order,
  }) async {
    final imageUrl = await _uploadCompressedImage(imageBytes);
    final docRef = _collection.doc();
    final banner = BannerModel(
      id: docRef.id,
      imageUrl: imageUrl,
      order: order,
    );
    await docRef.set(banner.toFirestore());
    return banner;
  }

  Future<BannerModel> updateBanner({
    required BannerModel banner,
    Uint8List? imageBytes,
    required int order,
  }) async {
    var imageUrl = banner.imageUrl;

    if (imageBytes != null) {
      await _deleteStorageFileIfOwned(banner.imageUrl);
      imageUrl = await _uploadCompressedImage(imageBytes);
    }

    final updated = banner.copyWith(imageUrl: imageUrl, order: order);
    await _collection.doc(banner.id).update(updated.toFirestore());
    return updated;
  }

  Future<void> deleteBanner(BannerModel banner) async {
    await _collection.doc(banner.id).delete();
    await _deleteStorageFileIfOwned(banner.imageUrl);
  }

  Future<String> _uploadCompressedImage(Uint8List imageBytes) async {
    final compressed = await ImageCompressor.compress(imageBytes);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('banners').child(fileName);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'public,max-age=31536000',
    );

    await ref.putData(compressed, metadata);
    return ref.getDownloadURL();
  }

  Future<void> _deleteStorageFileIfOwned(String imageUrl) async {
    if (!StorageUrl.isFirebaseStorage(imageUrl)) return;

    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {
      // Ignore missing/orphaned files so Firestore delete still succeeds.
    }
  }
}
