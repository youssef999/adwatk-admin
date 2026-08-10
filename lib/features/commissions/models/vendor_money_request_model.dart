import 'package:cloud_firestore/cloud_firestore.dart';

class VendorMoneyRequestModel {
  const VendorMoneyRequestModel({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.phone,
    required this.shopName,
    required this.status,
    required this.vendorsWalletIds,
    required this.workerId,
    this.createdAt,
  });

  final String id;
  final num amount;
  final String paymentMethod;
  final String phone;
  final String shopName;
  final String status;
  final List<String> vendorsWalletIds;
  final String workerId;
  final DateTime? createdAt;

  bool get isPending => status.trim().toLowerCase() == 'pending';
  bool get isSent => status.trim().toLowerCase() == 'sent';
  bool get isRejected => status.trim().toLowerCase() == 'rejected';

  VendorMoneyRequestModel copyWith({String? status}) {
    return VendorMoneyRequestModel(
      id: id,
      amount: amount,
      paymentMethod: paymentMethod,
      phone: phone,
      shopName: shopName,
      status: status ?? this.status,
      vendorsWalletIds: vendorsWalletIds,
      workerId: workerId,
      createdAt: createdAt,
    );
  }

  factory VendorMoneyRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ids = data['vendors_wallet_ids'];
    return VendorMoneyRequestModel(
      id: doc.id,
      amount: data['amount'] as num? ?? 0,
      paymentMethod: data['paymentMethod'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      status: data['status'] as String? ?? '',
      vendorsWalletIds: ids is List
          ? ids.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      workerId: data['workerId'] as String? ?? '',
      createdAt: _readTimestamp(data['createdAt']),
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
