import 'package:cloud_firestore/cloud_firestore.dart';

class VendorWalletModel {
  const VendorWalletModel({
    required this.id,
    required this.amount,
    required this.appCommission,
    required this.commissionPercent,
    required this.currency,
    required this.customerId,
    required this.customerName,
    required this.orderId,
    required this.orderPrice,
    required this.paymentTransactionId,
    required this.paymentType,
    required this.productId,
    required this.productName,
    required this.requestId,
    required this.shipmentCompanyId,
    required this.shipmentCompanyName,
    required this.shipmentOfferId,
    required this.shippingPrice,
    required this.status,
    required this.vendorId,
    this.completedAt,
    this.createdAt,
  });

  final String id;
  final num amount;
  final num appCommission;
  final num commissionPercent;
  final String currency;
  final String customerId;
  final String customerName;
  final String orderId;
  final num orderPrice;
  final String paymentTransactionId;
  final String paymentType;
  final String productId;
  final String productName;
  final String requestId;
  final String shipmentCompanyId;
  final String shipmentCompanyName;
  final String shipmentOfferId;
  final num shippingPrice;
  final String status;
  final String vendorId;
  final DateTime? completedAt;
  final DateTime? createdAt;

  bool get isDone => status.trim().toLowerCase() == 'done';
  bool get isRequestSent => status.trim().toLowerCase() == 'request_sent';
  bool get isSent => status.trim().toLowerCase() == 'sent';
  bool get isPending => status.trim().toLowerCase() == 'pending';

  /// `done` and `request_sent` can be converted to `sent`.
  bool get canMarkAsSent => isDone || isRequestSent;

  /// Lower = higher list priority (action needed first).
  int get listPriority {
    if (isRequestSent) return 0;
    if (isDone) return 1;
    if (isPending) return 2;
    if (isSent) return 3;
    return 4;
  }

  DateTime? get effectiveAt => completedAt ?? createdAt;

  VendorWalletModel copyWith({String? status}) {
    return VendorWalletModel(
      id: id,
      amount: amount,
      appCommission: appCommission,
      commissionPercent: commissionPercent,
      currency: currency,
      customerId: customerId,
      customerName: customerName,
      orderId: orderId,
      orderPrice: orderPrice,
      paymentTransactionId: paymentTransactionId,
      paymentType: paymentType,
      productId: productId,
      productName: productName,
      requestId: requestId,
      shipmentCompanyId: shipmentCompanyId,
      shipmentCompanyName: shipmentCompanyName,
      shipmentOfferId: shipmentOfferId,
      shippingPrice: shippingPrice,
      status: status ?? this.status,
      vendorId: vendorId,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

  factory VendorWalletModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return VendorWalletModel(
      id: doc.id,
      amount: data['amount'] as num? ?? 0,
      appCommission: data['app_commission'] as num? ?? 0,
      commissionPercent: data['commission_percent'] as num? ?? 0,
      currency: data['currency'] as String? ?? '',
      customerId: data['customer_id'] as String? ?? '',
      customerName: data['customer_name'] as String? ?? '',
      orderId: data['order_id'] as String? ?? '',
      orderPrice: data['order_price'] as num? ?? 0,
      paymentTransactionId: data['payment_transaction_id'] as String? ?? '',
      paymentType: data['payment_type'] as String? ?? '',
      productId: data['product_id'] as String? ?? '',
      productName: data['product_name'] as String? ?? '',
      requestId: data['request_id'] as String? ?? '',
      shipmentCompanyId: data['shipment_company_id'] as String? ?? '',
      shipmentCompanyName: data['shipment_company_name'] as String? ?? '',
      shipmentOfferId: data['shipment_offer_id'] as String? ?? '',
      shippingPrice: data['shipping_price'] as num? ?? 0,
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
