import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.order,
  });

  final String id;
  final String imageUrl;
  final int order;

  factory BannerModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'order': order,
    };
  }

  BannerModel copyWith({
    String? id,
    String? imageUrl,
    int? order,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
    );
  }
}
