class ViewInHomeModel {
  const ViewInHomeModel({
    required this.uid,
    required this.showStores,
    required this.showClientOffers,
  });

  final String uid;
  final bool showStores;
  final bool showClientOffers;

  factory ViewInHomeModel.fromMap(String uid, Map<String, dynamic> data) {
    final rawStores = data['stores'];
    final rawClientOffers = data['clinet_offers'] ?? data['client_offers'];
    return ViewInHomeModel(
      uid: uid,
      showStores: rawStores is bool ? rawStores : true,
      showClientOffers: rawClientOffers is bool ? rawClientOffers : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Firestore key kept as-is to match existing mobile app data.
      'clinet_offers': showClientOffers,
      'stores': showStores,
    };
  }

  ViewInHomeModel copyWith({
    bool? showStores,
    bool? showClientOffers,
  }) {
    return ViewInHomeModel(
      uid: uid,
      showStores: showStores ?? this.showStores,
      showClientOffers: showClientOffers ?? this.showClientOffers,
    );
  }
}
