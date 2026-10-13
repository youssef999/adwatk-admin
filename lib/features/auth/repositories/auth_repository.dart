import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/admin_access.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/routes/app_routes.dart';

/// Who is using the panel. Moderators only see shipping sections.
enum PanelRole { none, admin, moderator }

class AdminAccessDeniedException implements Exception {
  const AdminAccessDeniedException({this.asModerator = false});

  final bool asModerator;
}

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  PanelRole _role = PanelRole.none;
  String moderatorName = '';

  User? get currentUser => _auth.currentUser;
  PanelRole get role => _role;
  bool get isSignedIn => _role != PanelRole.none;
  bool get isAdmin => _role == PanelRole.admin;
  bool get isModerator => _role == PanelRole.moderator;

  /// Kept for existing callers: true for admin or moderator sessions.
  bool get isAdminSignedIn => isSignedIn;

  /// First page after login for the current role.
  String get homeRoute =>
      isModerator ? AppRoutes.shippingStores : AppRoutes.banners;

  /// Resolves the role of a persisted session (call once at startup).
  Future<void> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      _role = PanelRole.none;
      return;
    }
    try {
      _role = await _resolveRole(user);
    } catch (_) {
      _role = PanelRole.none;
    }
    if (_role == PanelRole.none) await _auth.signOut();
  }

  Future<void> signIn({
    required String email,
    required String password,
    bool asModerator = false,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    var resolved = PanelRole.none;
    if (user != null) {
      try {
        resolved = await _resolveRole(user, forceRefresh: true);
      } catch (_) {
        resolved = PanelRole.none;
      }
    }

    final expected = asModerator ? PanelRole.moderator : PanelRole.admin;
    if (resolved != expected) {
      _role = PanelRole.none;
      await _auth.signOut();
      throw AdminAccessDeniedException(asModerator: asModerator);
    }
    _role = resolved;
  }

  Future<void> signOut() async {
    _role = PanelRole.none;
    moderatorName = '';
    await _auth.signOut();
  }

  /// Admin by email allow-list; moderator by Auth claim + active
  /// `moderators/{id}` doc.
  Future<PanelRole> _resolveRole(User user, {bool forceRefresh = false}) async {
    if (AdminAccess.isAdminEmail(user.email)) return PanelRole.admin;

    final token = await user.getIdTokenResult(forceRefresh);
    final claims = token.claims ?? const {};
    final moderatorId = claims['moderator_id'];
    if (claims['role'] != 'moderator' || moderatorId is! String) {
      return PanelRole.none;
    }

    final doc = await _firestore
        .collection(FirestoreCollections.moderators)
        .doc(moderatorId)
        .get();
    final data = doc.data();
    if (data == null || data['active'] == false) return PanelRole.none;

    moderatorName = (data['name'] as String?)?.trim() ?? '';
    return PanelRole.moderator;
  }
}
