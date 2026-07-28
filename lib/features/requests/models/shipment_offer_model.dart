import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentOfferModel {
  const ShipmentOfferModel({
    required this.id,
    required this.offerId,
    required this.requestId,
    required this.requestUid,
    required this.uid,
    required this.email,
    required this.notes,
    required this.shippingPrice,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String offerId;
  final String requestId;
  final String requestUid;
  final String uid;
  final String email;
  final String notes;
  final num shippingPrice;
  final String status;
  final DateTime? createdAt;

  factory ShipmentOfferModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ShipmentOfferModel(
      id: doc.id,
      offerId: data['offerId'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      requestUid: data['requestUid'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      shippingPrice: data['shippingPrice'] as num? ?? 0,
      status: data['status'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
