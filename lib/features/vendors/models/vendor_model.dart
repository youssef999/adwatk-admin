import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/user_roles.dart';

class VendorModel {
  const VendorModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.shopName,
    required this.address,
    required this.shopLat,
    required this.shopLng,
    required this.specializations,
    this.fcmToken,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String email;
  final String phoneNumber;
  final String role;
  final String shopName;
  final String address;
  final double shopLat;
  final double shopLng;
  final List<String> specializations;
  final String? fcmToken;
  final DateTime? createdAt;

  bool get isTestWorker => role == UserRoles.testWorker;

  factory VendorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final specs = data['specializations'];
    return VendorModel(
      id: doc.id,
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: data['role'] as String? ?? UserRoles.worker,
      shopName: data['shopName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      shopLat: (data['shopLat'] as num?)?.toDouble() ?? 0,
      shopLng: (data['shopLng'] as num?)?.toDouble() ?? 0,
      specializations: specs is List
          ? specs.map((e) => e.toString()).toList()
          : const [],
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore({bool includeCreatedAt = false}) {
    return {
      'uid': uid,
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'role': role,
      'shopName': shopName.trim(),
      'address': address.trim(),
      'shopLat': shopLat,
      'shopLng': shopLng,
      'specializations': specializations,
      'fcmToken': fcmToken,
      if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  VendorModel copyWith({
    String? email,
    String? phoneNumber,
    String? role,
    String? shopName,
    String? address,
    double? shopLat,
    double? shopLng,
    List<String>? specializations,
    String? fcmToken,
  }) {
    return VendorModel(
      id: id,
      uid: uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      shopLat: shopLat ?? this.shopLat,
      shopLng: shopLng ?? this.shopLng,
      specializations: specializations ?? this.specializations,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
