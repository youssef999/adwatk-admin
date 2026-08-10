import 'package:cloud_firestore/cloud_firestore.dart';

class UserWalletModel {
  const UserWalletModel({
    required this.docId,
    required this.amount,
    required this.userEmail,
    required this.userId,
    this.createdAt,
  });

  final String docId;
  final num amount;
  final String userEmail;
  final String userId;
  final DateTime? createdAt;

  factory UserWalletModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawAmount = data['amount'];
    num amount = 0;
    if (rawAmount is num) {
      amount = rawAmount;
    } else if (rawAmount is String) {
      amount = num.tryParse(rawAmount.replaceAll(',', '.')) ?? 0;
    }

    return UserWalletModel(
      docId: doc.id,
      amount: amount,
      userEmail: data['user_email'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  UserWalletModel copyWith({num? amount}) {
    return UserWalletModel(
      docId: docId,
      amount: amount ?? this.amount,
      userEmail: userEmail,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
