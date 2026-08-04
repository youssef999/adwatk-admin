import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentWalletModel {
  const ShipmentWalletModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.customerId,
    required this.customerName,
    required this.orderId,
    required this.paymentTransactionId,
    required this.paymentType,
    required this.productId,
    required this.productName,
    required this.requestId,
    required this.shipmentCompanyId,
    required this.shipmentCompanyName,
    required this.shipmentOfferId,
    required this.status,
    required this.vendorId,
    this.completedAt,
    this.createdAt,
  });

  final String id;
  final num amount;
  final String currency;
  final String customerId;
  final String customerName;
  final String orderId;
  final String paymentTransactionId;
  final String paymentType;
  final String productId;
  final String productName;
  final String requestId;
  final String shipmentCompanyId;
  final String shipmentCompanyName;
  final String shipmentOfferId;
  final String status;
  final String vendorId;
  final DateTime? completedAt;
  final DateTime? createdAt;

  bool get isDone => status.trim().toLowerCase() == 'done';
  bool get isPending => status.trim().toLowerCase() == 'pending';
  bool get isSent => status.trim().toLowerCase() == 'sent';

  /// Lower = higher list priority (action needed / done first).
  int get listPriority {
    if (isDone) return 0;
    if (isPending) return 1;
    if (isSent) return 2;
    return 3;
  }

  DateTime? get effectiveAt => completedAt ?? createdAt;

  ShipmentWalletModel copyWith({String? status}) {
    return ShipmentWalletModel(
      id: id,
      amount: amount,
      currency: currency,
      customerId: customerId,
      customerName: customerName,
      orderId: orderId,
      paymentTransactionId: paymentTransactionId,
      paymentType: paymentType,
      productId: productId,
      productName: productName,
      requestId: requestId,
      shipmentCompanyId: shipmentCompanyId,
      shipmentCompanyName: shipmentCompanyName,
      shipmentOfferId: shipmentOfferId,
      status: status ?? this.status,
      vendorId: vendorId,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

  factory ShipmentWalletModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ShipmentWalletModel(
      id: doc.id,
      amount: data['amount'] as num? ?? 0,
      currency: data['currency'] as String? ?? '',
      customerId: data['customer_id'] as String? ?? '',
      customerName: data['customer_name'] as String? ?? '',
      orderId: data['order_id'] as String? ?? '',
      paymentTransactionId: data['payment_transaction_id'] as String? ?? '',
      paymentType: data['payment_type'] as String? ?? '',
      productId: data['product_id'] as String? ?? '',
      productName: data['product_name'] as String? ?? '',
      requestId: data['request_id'] as String? ?? '',
      shipmentCompanyId: data['shipment_company_id'] as String? ?? '',
      shipmentCompanyName: data['shipment_company_name'] as String? ?? '',
      shipmentOfferId: data['shipment_offer_id'] as String? ?? '',
      status: data['status'] as String? ?? '',
      vendorId: data['vendor_id'] as String? ?? '',
      completedAt: _readTimestamp(data['completedAt']),
      createdAt: _readTimestamp(data['created_at']),
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
