import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentRequestMoneyModel {
  const ShipmentRequestMoneyModel({
    required this.id,
    required this.amount,
    required this.howToGetMoney,
    required this.paymentMethod,
    required this.phone,
    required this.status,
    required this.transIds,
    required this.userEmail,
    required this.userId,
    this.createdAt,
  });

  final String id;
  final num amount;
  final String howToGetMoney;
  final String paymentMethod;
  final String phone;
  final String status;
  final List<String> transIds;
  final String userEmail;
  final String userId;
  final DateTime? createdAt;

  bool get isPending => status.trim().toLowerCase() == 'pending';
  bool get isSent => status.trim().toLowerCase() == 'sent';
  bool get isRejected => status.trim().toLowerCase() == 'rejected';

  ShipmentRequestMoneyModel copyWith({String? status}) {
    return ShipmentRequestMoneyModel(
      id: id,
      amount: amount,
      howToGetMoney: howToGetMoney,
      paymentMethod: paymentMethod,
      phone: phone,
      status: status ?? this.status,
      transIds: transIds,
      userEmail: userEmail,
      userId: userId,
      createdAt: createdAt,
    );
  }

  factory ShipmentRequestMoneyModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ids = data['trans_ids'];
    return ShipmentRequestMoneyModel(
      id: doc.id,
      amount: data['amount'] as num? ?? 0,
      howToGetMoney: data['how_to_get_money'] as String? ?? '',
      paymentMethod: data['payment_method'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      status: data['status'] as String? ?? '',
      transIds: ids is List
          ? ids.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      userEmail: data['user_email'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      createdAt: _readTimestamp(data['createdAt']),
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
