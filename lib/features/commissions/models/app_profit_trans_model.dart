import 'package:cloud_firestore/cloud_firestore.dart';

class AppProfitTransModel {
  const AppProfitTransModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentType,
    required this.orderId,
    required this.paymentTransactionId,
    required this.requestId,
    required this.shipmentId,
    required this.shipmentOrderId,
    this.completedAt,
    this.createdAt,
    this.date,
  });

  final String id;

  /// Prefer Firestore `amount`; falls back to legacy `mount` typo.
  final num amount;
  final String status;
  final String paymentType;
  final String orderId;
  final String paymentTransactionId;
  final String requestId;
  final String shipmentId;
  final String shipmentOrderId;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? date;

  bool get isDone => status.trim().toLowerCase() == 'done';
  bool get isPending => status.trim().toLowerCase() == 'pending';

  /// Prefer completion time, then creation, then parsed `date` string.
  DateTime? get effectiveAt => completedAt ?? createdAt ?? date;

  factory AppProfitTransModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppProfitTransModel(
      id: doc.id,
      amount: data['amount'] as num? ?? data['mount'] as num? ?? 0,
      status: data['status'] as String? ?? '',
      paymentType: data['payment_type'] as String? ?? '',
      orderId: data['order_id'] as String? ?? '',
      paymentTransactionId: data['payment_transaction_id'] as String? ?? '',
      requestId: data['request_id'] as String? ?? '',
      shipmentId: data['shipment_id'] as String? ?? '',
      shipmentOrderId: data['shipment_order_id'] as String? ?? '',
      completedAt: _readTimestamp(data['completedAt']),
      createdAt: _readTimestamp(data['created_at']),
      date: _readDate(data['date']),
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }
}
