import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryFeeModel {
  const DeliveryFeeModel({
    required this.id,
    required this.inCity,
    required this.outCity,
  });

  /// Known settings document in `delivery_fee`.
  static const String documentId = '6nqWvfl8ZVO6lpNtGY2L';

  final String id;
  final num inCity;
  final num outCity;

  factory DeliveryFeeModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return DeliveryFeeModel(
      id: doc.id,
      inCity: data['in_city'] as num? ?? 0,
      outCity: data['out_city'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    final inValue = inCity % 1 == 0 ? inCity.toInt() : inCity;
    final outValue = outCity % 1 == 0 ? outCity.toInt() : outCity;
    return {
      'in_city': inValue,
      'out_city': outValue,
    };
  }

  DeliveryFeeModel copyWith({num? inCity, num? outCity}) {
    return DeliveryFeeModel(
      id: id,
      inCity: inCity ?? this.inCity,
      outCity: outCity ?? this.outCity,
    );
  }
}
