import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  const RequestModel({
    required this.id,
    required this.uid,
    required this.partName,
    required this.description,
    required this.imageUrl,
    required this.carBrand,
    required this.carType,
    required this.status,
    required this.userAddress,
    required this.userLat,
    required this.userLng,
    required this.vin,
    required this.notificationSent,
    this.createdAt,
    this.shipmentOfferId,
    this.shipmentOfferPrice,
    this.shipmentStatus,
    this.shipmentShipperUid,
    this.shipmentOfferAt,
  });

  final String id;
  final String uid;
  final String partName;
  final String description;
  final String imageUrl;
  final String carBrand;
  final String carType;
  final String status;
  final String userAddress;
  final double userLat;
  final double userLng;
  final String vin;
  final bool notificationSent;
  final DateTime? createdAt;
  final String? shipmentOfferId;
  final num? shipmentOfferPrice;
  final String? shipmentStatus;
  final String? shipmentShipperUid;
  final DateTime? shipmentOfferAt;

  bool get hasShipmentOffer =>
      shipmentOfferId != null && shipmentOfferId!.isNotEmpty;

  String get carBrandLabel {
    final cleaned = carBrand.replaceFirst(RegExp(r'^brand_'), '');
    return cleaned
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  factory RequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return RequestModel(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      partName: data['partName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      carBrand: data['carBrand'] as String? ?? '',
      carType: data['carType'] as String? ?? '',
      status: data['status'] as String? ?? '',
      userAddress: data['userAddress'] as String? ?? '',
      userLat: (data['user_lat'] as num?)?.toDouble() ?? 0,
      userLng: (data['user_lng'] as num?)?.toDouble() ?? 0,
      vin: data['vin'] as String? ?? '',
      notificationSent: data['notificationSent'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      shipmentOfferId: data['shipmentOfferId'] as String?,
      shipmentOfferPrice: data['shipmentOfferPrice'] as num?,
      shipmentStatus: data['shipmentStatus'] as String?,
      shipmentShipperUid: data['shipmentShipperUid'] as String?,
      shipmentOfferAt: (data['shipmentOfferAt'] as Timestamp?)?.toDate(),
    );
  }
}
