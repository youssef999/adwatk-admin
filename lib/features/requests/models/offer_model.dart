import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  const OfferModel({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.workerId,
    required this.workerName,
    required this.shopName,
    required this.price,
    required this.condition,
    required this.warrantyPeriod,
    required this.status,
    required this.storeLat,
    required this.storeLng,
    this.createdAt,
  });

  final String id;
  final String requestId;
  final String customerId;
  final String workerId;
  final String workerName;
  final String shopName;
  final num price;
  final String condition;
  final String warrantyPeriod;
  final String status;
  final double storeLat;
  final double storeLng;
  final DateTime? createdAt;

  bool get isAccepted => status.toLowerCase() == 'accepted';

  factory OfferModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return OfferModel(
      id: doc.id,
      requestId: data['requestId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      workerId: data['workerId'] as String? ?? '',
      workerName: data['workerName'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      price: data['price'] as num? ?? 0,
      condition: data['condition'] as String? ?? '',
      warrantyPeriod: data['warrantyPeriod'] as String? ?? '',
      status: data['status'] as String? ?? '',
      storeLat: (data['store_lat'] as num?)?.toDouble() ?? 0,
      storeLng: (data['store_lng'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
