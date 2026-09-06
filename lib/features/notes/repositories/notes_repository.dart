import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../models/note_audience.dart';
import '../models/note_banner_model.dart';
import '../models/note_type.dart';

class NotesRepository {
  NotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.notiNotesBanner);

  Future<List<NoteBannerModel>> fetchNotes() async {
    // Do not orderBy createdAt in Firestore: docs without that field are
    // excluded (existing notes may only have title/details/to/type).
    final snapshot = await _collection.get();
    final list = snapshot.docs.map(NoteBannerModel.fromFirestore).toList();
    list.sort(
      (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );
    return list;
  }

  Future<NoteBannerModel> createNote({
    required String title,
    required String details,
    String type = NoteType.noti,
    String to = NoteAudience.clients,
  }) async {
    final docRef = _collection.doc();
    final note = NoteBannerModel(
      id: docRef.id,
      title: title,
      details: details,
      type: NoteType.normalize(type),
      to: NoteAudience.normalize(to),
    );
    await docRef.set(note.toFirestore());
    final saved = await docRef.get();
    return NoteBannerModel.fromFirestore(saved);
  }

  Future<void> deleteNote(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;
    await _collection.doc(trimmed).delete();
  }
}
