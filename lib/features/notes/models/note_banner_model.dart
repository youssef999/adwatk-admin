import 'package:cloud_firestore/cloud_firestore.dart';

import 'note_audience.dart';
import 'note_type.dart';

class NoteBannerModel {
  const NoteBannerModel({
    required this.id,
    required this.title,
    required this.details,
    required this.type,
    required this.to,
    this.customerUid = '',
    this.customerEmail = '',
    this.customerPhone = '',
    this.createdAt,
  });

  final String id;
  final String title;
  final String details;
  final String type;

  /// Firestore key `to`: clients | vendors | shipments
  final String to;
  final String customerUid;
  final String customerEmail;
  final String customerPhone;
  final DateTime? createdAt;

  String get toLabelAr => NoteAudience.labelAr(to);
  String get typeLabelAr => NoteType.labelAr(type);

  factory NoteBannerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return NoteBannerModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      type: NoteType.normalize(data['type'] as String?),
      to: NoteAudience.normalize(data['to'] as String?),
      customerUid: data['customer_uid'] as String? ?? '',
      customerEmail: data['customer_email'] as String? ?? '',
      customerPhone: data['customer_phone'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'details': details.trim(),
      'type': NoteType.normalize(type),
      'to': NoteAudience.normalize(to),
      if (customerUid.trim().isNotEmpty) 'customer_uid': customerUid.trim(),
      if (customerEmail.trim().isNotEmpty)
        'customer_email': customerEmail.trim(),
      if (customerPhone.trim().isNotEmpty)
        'customer_phone': customerPhone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
