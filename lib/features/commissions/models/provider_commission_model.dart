import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderCommissionModel {
  const ProviderCommissionModel({
    required this.id,
    required this.appCommission,
    required this.commissionPercent,
    required this.offerId,
    required this.price,
    required this.providerCommission,
    required this.requestId,
    required this.shopName,
    required this.workerId,
    this.createdAt,
  });

  final String id;
  final num appCommission;
  final num commissionPercent;
  final String offerId;
  final num price;
  final num providerCommission;
  final String requestId;
  final String shopName;
  final String workerId;
  final DateTime? createdAt;

  factory ProviderCommissionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ProviderCommissionModel(
      id: doc.id,
      appCommission: data['appCommission'] as num? ?? 0,
      commissionPercent: data['commissionPercent'] as num? ?? 0,
      offerId: data['offerId'] as String? ?? '',
      price: data['price'] as num? ?? 0,
      providerCommission: data['providerCommission'] as num? ?? 0,
      requestId: data['requestId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      workerId: data['workerId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
