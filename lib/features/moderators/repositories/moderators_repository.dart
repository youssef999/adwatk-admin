import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../models/moderator_model.dart';

class ModeratorsRepository {
  ModeratorsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.moderators);

  /// Live list so the Auth sync status updates without a manual refresh.
  Stream<List<ModeratorModel>> watchModerators() {
    return _collection.snapshots().map((snap) {
      final list = snap.docs.map(ModeratorModel.fromFirestore).toList();
      list.sort(
        (a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)),
      );
      return list;
    });
  }

  Future<void> createModerator({
    required String email,
    required String name,
    required String password,
    required bool active,
  }) async {
    await _collection.add({
      'email': email.trim().toLowerCase(),
      'name': name.trim(),
      'password': password,
      'active': active,
      'auth_status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// [password] is only written when the admin sets a new one.
  Future<void> updateModerator({
    required String id,
    required String email,
    required String name,
    required bool active,
    String? password,
  }) async {
    final hasPassword = password != null && password.isNotEmpty;
    await _collection.doc(id).update({
      'email': email.trim().toLowerCase(),
      'name': name.trim(),
      'active': active,
      if (hasPassword) 'password': password,
      if (hasPassword) 'auth_status': 'pending',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setActive(String id, bool active) async {
    await _collection.doc(id).update({
      'active': active,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteModerator(String id) async {
    await _collection.doc(id).delete();
  }
}
