import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTransactionModel {
  const PaymentTransactionModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.createdAt,
  });

  final String id;
  final num amount;
  final String currency;
  final String method;
  final String status;
  final DateTime? createdAt;

  factory PaymentTransactionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return PaymentTransactionModel(
      id: doc.id,
      amount: data['amount'] as num? ?? 0,
      currency: data['currency'] as String? ?? 'IQD',
      method: (data['method'] as String?) ??
          (data['payment_type'] as String?) ??
          '',
      status: data['status'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
