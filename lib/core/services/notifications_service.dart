import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import 'fcm/fcm_notification_sender.dart';

class AdminNotificationResult {
  const AdminNotificationResult({
    required this.fcmSent,
    required this.firestoreSaved,
    this.error,
  });

  final bool fcmSent;
  final bool firestoreSaved;
  final String? error;

  bool get success => fcmSent && firestoreSaved;
}

/// Writes `notifications/{recipientId}/items` and sends FCM push.
class NotificationsService {
  NotificationsService({
    FirebaseFirestore? firestore,
    FcmNotificationSender? fcmSender,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _fcmSender = fcmSender ?? FcmNotificationSender();

  final FirebaseFirestore _firestore;
  final FcmNotificationSender _fcmSender;

  CollectionReference<Map<String, dynamic>> _itemsRef(String recipientId) =>
      _firestore
          .collection(FirestoreCollections.notifications)
          .doc(recipientId)
          .collection('items');

  Future<AdminNotificationResult> sendAdminNotification({
    required String recipientId,
    required String? fcmToken,
    required String title,
    required String body,
  }) async {
    final uid = recipientId.trim();
    final cleanTitle = title.trim();
    final cleanBody = body.trim();

    if (uid.isEmpty) {
      return const AdminNotificationResult(
        fcmSent: false,
        firestoreSaved: false,
        error: 'معرف المستلم غير موجود',
      );
    }
    if (cleanTitle.isEmpty || cleanBody.isEmpty) {
      return const AdminNotificationResult(
        fcmSent: false,
        firestoreSaved: false,
        error: 'العنوان والنص مطلوبان',
      );
    }

    var firestoreSaved = false;
    try {
      await _itemsRef(uid).add({
        'type': 'admin_message',
        'title': cleanTitle,
        'body': cleanBody,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        // Fields kept for app schema compatibility (offer-style items).
        'condition': '',
        'offerId': '',
        'price': 0,
        'requestId': '',
        'shopName': 'إدارة أدواتك',
        'warrantyPeriod': '',
      });
      firestoreSaved = true;
    } catch (e) {
      return AdminNotificationResult(
        fcmSent: false,
        firestoreSaved: false,
        error: 'تعذر حفظ الإشعار: $e',
      );
    }

    final token = (fcmToken ?? '').trim();
    if (token.isEmpty) {
      return const AdminNotificationResult(
        fcmSent: false,
        firestoreSaved: true,
        error: 'تم الحفظ بدون Push — لا يوجد FCM token',
      );
    }

    final fcmSent = await _fcmSender.sendToToken(
      token: token,
      title: cleanTitle,
      body: cleanBody,
      data: {
        'type': 'admin_message',
        'recipientId': uid,
      },
    );

    if (!fcmSent) {
      return AdminNotificationResult(
        fcmSent: false,
        firestoreSaved: firestoreSaved,
        error: _fcmSender.lastError ?? 'تعذر إرسال إشعار FCM',
      );
    }

    return const AdminNotificationResult(
      fcmSent: true,
      firestoreSaved: true,
    );
  }
}
