import 'package:cloud_firestore/cloud_firestore.dart';

/// A shipping moderator from `moderators/{id}`.
///
/// The plain `password` is never read back: the `onModeratorWritten` Cloud
/// Function moves it into Firebase Auth and deletes it, then writes
/// [authStatus] (`ready` / `error`) and [syncError].
class ModeratorModel {
  const ModeratorModel({
    required this.id,
    required this.email,
    required this.name,
    required this.active,
    required this.authStatus,
    required this.syncError,
    this.createdAt,
    this.syncedAt,
  });

  final String id;
  final String email;
  final String name;
  final bool active;
  final String authStatus;
  final String syncError;
  final DateTime? createdAt;
  final DateTime? syncedAt;

  bool get isReady => authStatus == 'ready';
  bool get hasError => authStatus == 'error';

  factory ModeratorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ModeratorModel(
      id: doc.id,
      email: (data['email'] as String?)?.trim() ?? '',
      name: (data['name'] as String?)?.trim() ?? '',
      active: data['active'] != false,
      authStatus: (data['auth_status'] as String?)?.trim() ?? '',
      syncError: (data['sync_error'] as String?)?.trim() ?? '',
      createdAt: _readTimestamp(data['created_at']),
      syncedAt: _readTimestamp(data['synced_at']),
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
