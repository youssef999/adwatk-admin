import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/user_roles.dart';

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.fcmToken,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? fcmToken;
  final DateTime? createdAt;

  factory CustomerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CustomerModel(
      id: doc.id,
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: data['role'] as String? ?? UserRoles.customer,
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore({bool includeCreatedAt = false}) {
    return {
      'uid': uid,
      'email': email.trim(),
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'role': UserRoles.customer,
      'fcmToken': fcmToken,
      if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  CustomerModel copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    String? fcmToken,
  }) {
    return CustomerModel(
      id: id,
      uid: uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
