import 'package:cloud_firestore/cloud_firestore.dart';

class IncentiveRequestModel {
  const IncentiveRequestModel({
    required this.id,
    required this.commissionDocIds,
    required this.incentiveAmount,
    required this.incentivePercent,
    required this.salesCount,
    required this.shopName,
    required this.status,
    required this.totalAppCommission,
    required this.workerId,
    this.createdAt,
  });

  final String id;
  final List<String> commissionDocIds;
  final num incentiveAmount;
  final num incentivePercent;
  final int salesCount;
  final String shopName;
  final String status;
  final num totalAppCommission;
  final String workerId;
  final DateTime? createdAt;

  factory IncentiveRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ids = data['commissionDocIds'];
    return IncentiveRequestModel(
      id: doc.id,
      commissionDocIds: ids is List
          ? ids.map((e) => e.toString()).toList()
          : const [],
      incentiveAmount: data['incentiveAmount'] as num? ?? 0,
      incentivePercent: data['incentivePercent'] as num? ?? 0,
      salesCount: (data['salesCount'] as num?)?.toInt() ?? 0,
      shopName: data['shopName'] as String? ?? '',
      status: data['status'] as String? ?? '',
      totalAppCommission: data['totalAppCommission'] as num? ?? 0,
      workerId: data['workerId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
