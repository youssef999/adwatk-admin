import 'package:cloud_firestore/cloud_firestore.dart';

/// Collection name in Firestore is intentionally `shippiment_stores` (as stored).
class ShippimentStoreModel {
  const ShippimentStoreModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileId,
    required this.profileImageUrl,
    required this.rate,
    required this.vehicleSizeType,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.fcmTokenUpdatedAt,
    this.profileImageUpdatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String profileId;
  final String profileImageUrl;
  final num rate;
  final String vehicleSizeType;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? fcmTokenUpdatedAt;
  final DateTime? profileImageUpdatedAt;

  static const List<String> vehicleSizeTypes = ['small', 'medium', 'large'];

  factory ShippimentStoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ShippimentStoreModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      profileId: data['profileId'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String? ?? '',
      rate: data['rate'] as num? ?? 0,
      vehicleSizeType: data['vehicleSizeType'] as String? ?? '',
      fcmToken: (data['fcmToken'] as String?) ?? (data['fcm_token'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      fcmTokenUpdatedAt: (data['fcmTokenUpdatedAt'] as Timestamp?)?.toDate(),
      profileImageUpdatedAt:
          (data['profileImageUpdatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateFirestore({required bool includeImageTimestamps}) {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'profileId': profileId.trim(),
      'profileImageUrl': profileImageUrl,
      'rate': rate,
      'vehicleSizeType': vehicleSizeType,
      'fcmToken': fcmToken,
      'fcm_token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (includeImageTimestamps)
        'profileImageUpdatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateFirestore({required bool imageChanged}) {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'profileId': profileId.trim(),
      'profileImageUrl': profileImageUrl,
      'rate': rate,
      'vehicleSizeType': vehicleSizeType,
      'updatedAt': FieldValue.serverTimestamp(),
      if (imageChanged) 'profileImageUpdatedAt': FieldValue.serverTimestamp(),
    };
  }

  ShippimentStoreModel copyWith({
    String? name,
    String? email,
    String? profileId,
    String? profileImageUrl,
    num? rate,
    String? vehicleSizeType,
    String? fcmToken,
  }) {
    return ShippimentStoreModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileId: profileId ?? this.profileId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rate: rate ?? this.rate,
      vehicleSizeType: vehicleSizeType ?? this.vehicleSizeType,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fcmTokenUpdatedAt: fcmTokenUpdatedAt,
      profileImageUpdatedAt: profileImageUpdatedAt,
    );
  }
}
