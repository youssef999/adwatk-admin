import 'package:cloud_firestore/cloud_firestore.dart';

class AppCommissionModel {
  const AppCommissionModel({
    required this.id,
    required this.value,
  });

  final String id;
  final num value;

  factory AppCommissionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppCommissionModel(
      id: doc.id,
      value: data['value'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {'value': value};

  AppCommissionModel copyWith({num? value}) {
    return AppCommissionModel(
      id: id,
      value: value ?? this.value,
    );
  }
}
