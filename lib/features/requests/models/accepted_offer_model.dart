import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptedOfferModel {
  const AcceptedOfferModel({
    required this.id,
    required this.offerId,
    required this.requestId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.partName,
    required this.partDescription,
    required this.price,
    required this.condition,
    required this.carType,
    required this.vin,
    required this.warrantyPeriod,
    required this.shopId,
    required this.shopName,
    required this.shopEmail,
    required this.shopPhone,
    required this.shopAddress,
    required this.shopSpecializations,
    this.requestImageUrl,
    this.acceptedAt,
    this.offerCreatedAt,
    this.requestCreatedAt,
  });

  final String id;
  final String offerId;
  final String requestId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String partName;
  final String partDescription;
  final num price;
  final String condition;
  final String carType;
  final String vin;
  final String warrantyPeriod;
  final String shopId;
  final String shopName;
  final String shopEmail;
  final String shopPhone;
  final String shopAddress;
  final List<String> shopSpecializations;
  final String? requestImageUrl;
  final DateTime? acceptedAt;
  final DateTime? offerCreatedAt;
  final DateTime? requestCreatedAt;

  factory AcceptedOfferModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final specs = data['shopSpecializations'];
    return AcceptedOfferModel(
      id: doc.id,
      offerId: data['offerId'] as String? ?? doc.id,
      requestId: data['requestId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      partName: data['partName'] as String? ?? '',
      partDescription: data['partDescription'] as String? ?? '',
      price: data['price'] as num? ?? 0,
      condition: data['condition'] as String? ?? '',
      carType: data['carType'] as String? ?? '',
      vin: data['vin'] as String? ?? '',
      warrantyPeriod: data['warrantyPeriod'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      shopEmail: data['shopEmail'] as String? ?? '',
      shopPhone: data['shopPhone'] as String? ?? '',
      shopAddress: data['shopAddress'] as String? ?? '',
      shopSpecializations: specs is List
          ? specs.map((e) => e.toString()).toList()
          : const [],
      requestImageUrl: data['requestImageUrl'] as String?,
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      offerCreatedAt: (data['offerCreatedAt'] as Timestamp?)?.toDate(),
      requestCreatedAt: (data['requestCreatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
