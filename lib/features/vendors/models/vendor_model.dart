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
    this.partsCategories = const [],
    this.workType = '',
    this.identityDocumentType = '',
    this.identityDocumentUrl = '',
    this.identityDocumentUpdatedAt,
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
  final List<String> partsCategories;
  final String workType;
  final String identityDocumentType;
  final String identityDocumentUrl;
  final DateTime? identityDocumentUpdatedAt;
  final String? fcmToken;
  final DateTime? createdAt;

  bool get isTestWorker => role == UserRoles.testWorker;

  bool get hasIdentityDocument =>
      identityDocumentType.trim().isNotEmpty ||
      identityDocumentUrl.trim().isNotEmpty ||
      identityDocumentUpdatedAt != null;

  String get identityDocumentTypeLabel {
    switch (identityDocumentType.trim().toLowerCase()) {
      case 'national_id':
      case 'nationalid':
        return 'بطاقة الهوية الوطنية';
      case 'passport':
        return 'جواز السفر';
      case 'residence':
        return 'إقامة';
      case 'driving_license':
      case 'drivinglicense':
        return 'رخصة القيادة';
      default:
        if (identityDocumentType.trim().isEmpty) return '—';
        return identityDocumentType.trim();
    }
  }

  factory VendorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final specs = data['specializations'];
    final parts = data['partsCategories'];
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
      partsCategories: parts is List
          ? parts.map((e) => e.toString()).toList()
          : const [],
      workType: data['workType'] as String? ?? '',
      identityDocumentType: data['identityDocumentType'] as String? ?? '',
      identityDocumentUrl: data['identityDocumentUrl'] as String? ?? '',
      identityDocumentUpdatedAt:
          (data['identityDocumentUpdatedAt'] as Timestamp?)?.toDate(),
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
      'partsCategories': partsCategories,
      'workType': workType.trim(),
      'identityDocumentType': identityDocumentType.trim(),
      'identityDocumentUrl': identityDocumentUrl.trim(),
      if (identityDocumentUpdatedAt != null)
        'identityDocumentUpdatedAt':
            Timestamp.fromDate(identityDocumentUpdatedAt!),
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
    List<String>? partsCategories,
    String? workType,
    String? identityDocumentType,
    String? identityDocumentUrl,
    DateTime? identityDocumentUpdatedAt,
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
      partsCategories: partsCategories ?? this.partsCategories,
      workType: workType ?? this.workType,
      identityDocumentType: identityDocumentType ?? this.identityDocumentType,
      identityDocumentUrl: identityDocumentUrl ?? this.identityDocumentUrl,
      identityDocumentUpdatedAt:
          identityDocumentUpdatedAt ?? this.identityDocumentUpdatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
