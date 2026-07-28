import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/constants/user_roles.dart';
import '../../vendors/models/vendor_model.dart';
import '../models/customer_model.dart';
import '../models/phone_lookup_model.dart';

class UsersRepository {
  UsersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _phoneLookup =>
      _firestore.collection(FirestoreCollections.phoneLookup);

  Future<List<CustomerModel>> fetchCustomers() async {
    try {
      final snapshot = await _collection
          .where('role', isEqualTo: UserRoles.customer)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(CustomerModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _collection
            .where('role', isEqualTo: UserRoles.customer)
            .get();
        final list = snapshot.docs.map(CustomerModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<VendorModel>> fetchVendors() async {
    try {
      final snapshot = await _collection
          .where('role', whereIn: UserRoles.vendorRoles)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(VendorModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        final snapshot = await _collection
            .where('role', whereIn: UserRoles.vendorRoles)
            .get();
        final list = snapshot.docs.map(VendorModel.fromFirestore).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      }
      rethrow;
    }
  }

  Future<List<PhoneLookupModel>> fetchPhoneLookups() async {
    final snapshot = await _phoneLookup.get();
    final list = snapshot.docs.map(PhoneLookupModel.fromFirestore).toList();
    list.sort((a, b) => a.phone.compareTo(b.phone));
    return list;
  }

  Future<void> upsertPhoneLookup({
    required String phone,
    required String email,
  }) async {
    final id = phone.trim();
    if (id.isEmpty) return;
    await _phoneLookup.doc(id).set({'email': email.trim()});
  }

  Future<void> deletePhoneLookup(String phone) async {
    final id = phone.trim();
    if (id.isEmpty) return;
    await _phoneLookup.doc(id).delete();
  }

  Future<void> syncPhoneLookup({
    String? previousPhone,
    required String phone,
    required String email,
  }) async {
    final next = phone.trim();
    final prev = previousPhone?.trim() ?? '';
    if (prev.isNotEmpty && prev != next) {
      await deletePhoneLookup(prev);
    }
    if (next.isNotEmpty && email.trim().isNotEmpty) {
      await upsertPhoneLookup(phone: next, email: email);
    }
  }

  Future<CustomerModel> createCustomer({
    required String email,
    required String fullName,
    required String phoneNumber,
  }) async {
    final docRef = _collection.doc();
    final customer = CustomerModel(
      id: docRef.id,
      uid: docRef.id,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: UserRoles.customer,
    );
    await docRef.set(customer.toFirestore(includeCreatedAt: true));
    await syncPhoneLookup(phone: phoneNumber, email: email);
    return customer;
  }

  Future<CustomerModel> updateCustomer(
    CustomerModel customer, {
    String? previousPhone,
  }) async {
    await _collection.doc(customer.id).update(customer.toFirestore());
    await syncPhoneLookup(
      previousPhone: previousPhone,
      phone: customer.phoneNumber,
      email: customer.email,
    );
    return customer;
  }

  Future<VendorModel> createVendor({
    required String email,
    required String phoneNumber,
    required String role,
    required String shopName,
    required String address,
    required double shopLat,
    required double shopLng,
    required List<String> specializations,
  }) async {
    final docRef = _collection.doc();
    final vendor = VendorModel(
      id: docRef.id,
      uid: docRef.id,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      shopName: shopName,
      address: address,
      shopLat: shopLat,
      shopLng: shopLng,
      specializations: specializations,
    );
    await docRef.set(vendor.toFirestore(includeCreatedAt: true));
    await syncPhoneLookup(phone: phoneNumber, email: email);
    return vendor;
  }

  Future<VendorModel> updateVendor(
    VendorModel vendor, {
    String? previousPhone,
  }) async {
    await _collection.doc(vendor.id).update(vendor.toFirestore());
    await syncPhoneLookup(
      previousPhone: previousPhone,
      phone: vendor.phoneNumber,
      email: vendor.email,
    );
    return vendor;
  }

  Future<void> deleteUser(
    String id, {
    String? phoneNumber,
  }) async {
    await _collection.doc(id).delete();
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      await deletePhoneLookup(phoneNumber);
    }
  }
}
