import 'package:cloud_firestore/cloud_firestore.dart';

class SalePartModel {
  const SalePartModel({
    required this.id,
    required this.uid,
    required this.sellerName,
    required this.partName,
    required this.description,
    required this.price,
    required this.condition,
    required this.carType,
    required this.carBrand,
    required this.imageUrl,
    required this.sellerAddress,
    required this.status,
    this.createdAt,
    this.sellerLat,
    this.sellerLng,
  });

  final String id;
  final String uid;
  final String sellerName;
  final String partName;
  final String description;
  final num price;
  final String condition;
  final String carType;
  final String carBrand;
  final String imageUrl;
  final String sellerAddress;
  final String status;
  final DateTime? createdAt;
  final double? sellerLat;
  final double? sellerLng;

  String get carBrandLabel {
    final cleaned = carBrand.replaceFirst(RegExp(r'^brand_'), '');
    return cleaned
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  factory SalePartModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SalePartModel(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      sellerName: data['sellerName'] as String? ?? '',
      partName: data['partName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: data['price'] as num? ?? 0,
      condition: data['condition'] as String? ?? '',
      carType: data['carType'] as String? ?? '',
      carBrand: data['carBrand'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      sellerAddress: data['sellerAddress'] as String? ?? '',
      status: data['status'] as String? ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      sellerLat: (data['sellerLat'] as num?)?.toDouble(),
      sellerLng: (data['sellerLng'] as num?)?.toDouble(),
    );
  }
}
