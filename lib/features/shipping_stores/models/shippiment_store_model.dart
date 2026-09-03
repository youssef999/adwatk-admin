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
    this.lat,
    this.lng,
    this.locationUpdatedAt,
    this.vehicleDistinctiveNumber = '',
    this.vehicleImageUrl = '',
    this.vehicleImageUpdatedAt,
    this.vehicleName = '',
    this.vehicleDriverName = '',
    this.vehicleType = '',
    this.createdAt,
    this.updatedAt,
    this.fcmTokenUpdatedAt,
    this.profileImageUpdatedAt,
    this.idDocumentType = '',
    this.idDocumentUrl = '',
    this.idDocumentUpdatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String profileId;
  final String profileImageUrl;
  final num rate;
  final String vehicleSizeType;
  final String? fcmToken;
  final double? lat;
  final double? lng;
  final DateTime? locationUpdatedAt;
  final String vehicleDistinctiveNumber;
  final String vehicleImageUrl;
  final DateTime? vehicleImageUpdatedAt;
  final String vehicleName;
  final String vehicleDriverName;
  final String vehicleType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? fcmTokenUpdatedAt;
  final DateTime? profileImageUpdatedAt;
  final String idDocumentType;
  final String idDocumentUrl;
  final DateTime? idDocumentUpdatedAt;

  static const List<String> vehicleSizeTypes = ['small', 'medium', 'large'];

  bool get hasLocation => lat != null && lng != null;

  /// Returns true if ANY identity document field is present (type, URL, or date).
  bool get hasIdDocument =>
      idDocumentType.trim().isNotEmpty ||
      idDocumentUrl.trim().isNotEmpty ||
      idDocumentUpdatedAt != null;

  /// Whether the document has a viewable image URL.
  bool get hasIdDocumentImage => idDocumentUrl.trim().isNotEmpty;

  String get idDocumentTypeLabel {
    switch (idDocumentType.trim().toLowerCase()) {
      case 'nationalid':
        return 'بطاقة الهوية الوطنية';
      case 'passport':
        return 'جواز السفر';
      case 'residence':
        return 'إقامة';
      case 'drivinglicense':
      case 'driving_license':
        return 'رخصة القيادة';
      default:
        if (idDocumentType.trim().isEmpty) return '—';
        return idDocumentType.trim();
    }
  }

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
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      locationUpdatedAt: (data['locationUpdatedAt'] as Timestamp?)?.toDate(),
      vehicleDistinctiveNumber:
          data['vehicleDistinctiveNumber'] as String? ?? '',
      vehicleImageUrl: data['vehicleImageUrl'] as String? ?? '',
      vehicleImageUpdatedAt:
          (data['vehicleImageUpdatedAt'] as Timestamp?)?.toDate(),
      vehicleName: data['vehicleName'] as String? ?? '',
      vehicleDriverName: data['vehicleDriverName'] as String? ?? '',
      vehicleType: data['vehicleType'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      fcmTokenUpdatedAt: (data['fcmTokenUpdatedAt'] as Timestamp?)?.toDate(),
      profileImageUpdatedAt:
          (data['profileImageUpdatedAt'] as Timestamp?)?.toDate(),
      idDocumentType: data['idDocumentType'] as String? ?? '',
      idDocumentUrl: data['idDocumentUrl'] as String? ?? '',
      idDocumentUpdatedAt:
          (data['idDocumentUpdatedAt'] as Timestamp?)?.toDate(),
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
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'vehicleDistinctiveNumber': vehicleDistinctiveNumber.trim(),
      'vehicleImageUrl': vehicleImageUrl,
      'vehicleName': vehicleName.trim(),
      'vehicleDriverName': vehicleDriverName.trim(),
      'vehicleType': vehicleType.trim().isEmpty
          ? vehicleSizeType
          : vehicleType.trim(),
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
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'vehicleDistinctiveNumber': vehicleDistinctiveNumber.trim(),
      'vehicleImageUrl': vehicleImageUrl,
      'vehicleName': vehicleName.trim(),
      'vehicleDriverName': vehicleDriverName.trim(),
      'vehicleType': vehicleType.trim().isEmpty
          ? vehicleSizeType
          : vehicleType.trim(),
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
    double? lat,
    double? lng,
    DateTime? locationUpdatedAt,
    String? vehicleDistinctiveNumber,
    String? vehicleImageUrl,
    DateTime? vehicleImageUpdatedAt,
    String? vehicleName,
    String? vehicleDriverName,
    String? vehicleType,
    String? idDocumentType,
    String? idDocumentUrl,
    DateTime? idDocumentUpdatedAt,
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
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
      vehicleDistinctiveNumber:
          vehicleDistinctiveNumber ?? this.vehicleDistinctiveNumber,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      vehicleImageUpdatedAt:
          vehicleImageUpdatedAt ?? this.vehicleImageUpdatedAt,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleDriverName: vehicleDriverName ?? this.vehicleDriverName,
      vehicleType: vehicleType ?? this.vehicleType,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fcmTokenUpdatedAt: fcmTokenUpdatedAt,
      profileImageUpdatedAt: profileImageUpdatedAt,
      idDocumentType: idDocumentType ?? this.idDocumentType,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      idDocumentUpdatedAt: idDocumentUpdatedAt ?? this.idDocumentUpdatedAt,
    );
  }
}
