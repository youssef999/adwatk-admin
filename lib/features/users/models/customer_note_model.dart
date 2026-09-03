import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerNoteModel {
  const CustomerNoteModel({
    required this.id,
    required this.customerUid,
    required this.customerEmail,
    required this.customerPhone,
    required this.title,
    required this.details,
    required this.type,
    this.createdAt,
  });

  final String id;
  final String customerUid;
  final String customerEmail;
  final String customerPhone;
  final String title;
  final String details;
  final String type;
  final DateTime? createdAt;

  factory CustomerNoteModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CustomerNoteModel(
      id: doc.id,
      customerUid: data['customer_uid'] as String? ?? '',
      customerEmail: data['customer_email'] as String? ?? '',
      customerPhone: data['customer_phone'] as String? ?? '',
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      type: data['type'] as String? ?? 'noti',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // Keys below keep compatibility with existing collection usage.
      'title': title.trim(),
      'details': details.trim(),
      'type': type.trim().isEmpty ? 'noti' : type.trim(),
      'customer_uid': customerUid.trim(),
      'customer_email': customerEmail.trim(),
      'customer_phone': customerPhone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
