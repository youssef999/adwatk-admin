import 'package:cloud_firestore/cloud_firestore.dart';

/// App commission deducted from the courier per delivered order
/// (`app_commission_shipemnt_values`). A value of 0 disables the deduction.
class ShipmentAppCommissionModel {
  const ShipmentAppCommissionModel({
    required this.id,
    required this.inCityValue,
    required this.outCityValue,
  });

  final String id;
  final int inCityValue;
  final int outCityValue;

  factory ShipmentAppCommissionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ShipmentAppCommissionModel(
      id: doc.id,
      inCityValue: _readInt(data['in_city']),
      outCityValue: _readInt(data['out_city']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'in_city': inCityValue,
      'out_city': outCityValue,
    };
  }

  static int _readInt(dynamic v) {
    if (v is num) return v.round();
    return int.tryParse(v?.toString().trim() ?? '') ?? 0;
  }
}
