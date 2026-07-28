import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneLookupModel {
  const PhoneLookupModel({
    required this.phone,
    required this.email,
  });

  final String phone;
  final String email;

  factory PhoneLookupModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return PhoneLookupModel(
      phone: doc.id,
      email: data['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {'email': email.trim()};
}
