import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/constants/user_roles.dart';
import '../../vendors/models/vendor_model.dart';
import '../models/customer_model.dart';
import '../models/phone_lookup_model.dart';
import '../models/user_wallet_model.dart';

class UsersRepository {
  UsersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _phoneLookup =>
      _firestore.collection(FirestoreCollections.phoneLookup);

  CollectionReference<Map<String, dynamic>> get _userMinWalletAlert =>
      _firestore.collection(FirestoreCollections.userMinWalletAlert);

  CollectionReference<Map<String, dynamic>> get _providerMinWalletAllert =>
      _firestore.collection(FirestoreCollections.providerMinWalletAllert);

  CollectionReference<Map<String, dynamic>> get _userWallet =>
      _firestore.collection(FirestoreCollections.userWallet);

  Future<List<UserWalletModel>> fetchUserWallets() async {
    final snapshot = await _userWallet.get();
    return snapshot.docs.map(UserWalletModel.fromFirestore).toList();
  }

  Future<DocumentReference<Map<String, dynamic>>> _resolveUserWalletRef({
    required String userId,
    required String userEmail,
  }) async {
    final id = userId.trim();
    final byDoc = _userWallet.doc(id);
    final byDocSnap = await byDoc.get();
    if (byDocSnap.exists) return byDoc;

    final byId = await _userWallet
        .where('user_id', isEqualTo: id)
        .limit(1)
        .get();
    if (byId.docs.isNotEmpty) return byId.docs.first.reference;

    final email = userEmail.trim();
    if (email.isNotEmpty) {
      final byEmail = await _userWallet
          .where('user_email', isEqualTo: email)
          .limit(1)
          .get();
      if (byEmail.docs.isNotEmpty) return byEmail.docs.first.reference;
    }

    return byDoc;
  }

  /// [delta] > 0 adds, [delta] < 0 subtracts. Uses `user_wallet/{userId}`.
  Future<UserWalletModel> adjustUserWallet({
    required String userId,
    required String userEmail,
    required num delta,
  }) async {
    final id = userId.trim();
    final email = userEmail.trim();
    if (id.isEmpty || email.isEmpty) {
      throw ArgumentError('userId and userEmail are required');
    }
    if (delta == 0) {
      throw ArgumentError('delta must not be zero');
    }

    final storedDelta = delta % 1 == 0 ? delta.toInt() : delta;
    final ref = await _resolveUserWalletRef(userId: id, userEmail: email);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          'amount': storedDelta,
          'created_at': FieldValue.serverTimestamp(),
          'user_email': email,
          'user_id': id,
        });
        return;
      }
      final current = _parseNumericValue(snap.data()?['amount']) ?? 0;
      final next = current + storedDelta;
      final storedNext = next % 1 == 0 ? next.toInt() : next;
      tx.update(ref, {
        'amount': storedNext,
        'user_email': email,
        'user_id': id,
      });
    });

    final updated = await ref.get();
    return UserWalletModel.fromFirestore(updated);
  }

  CollectionReference<Map<String, dynamic>> get _vendorsWallet =>
      _firestore.collection(FirestoreCollections.vendorsWallet);

  /// Sum of `vendors_wallet.amount` where `status == done`, keyed by `vendor_id`.
  Future<Map<String, num>> fetchVendorWalletBalances() async {
    final snapshot = await _vendorsWallet.get();
    final totals = <String, num>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = (data['status'] as String?)?.trim().toLowerCase() ?? '';
      if (status != 'done') continue;
      final vendorId = (data['vendor_id'] as String?)?.trim() ?? '';
      if (vendorId.isEmpty) continue;
      totals[vendorId] = (totals[vendorId] ?? 0) + (data['amount'] as num? ?? 0);
    }
    return totals;
  }

  Future<void> adjustVendorWalletBalance({
    required String vendorId,
    required num delta,
  }) async {
    final id = vendorId.trim();
    if (id.isEmpty || delta == 0) return;
    final amount = delta % 1 == 0 ? delta.toInt() : delta;
    await _vendorsWallet.add({
      'amount': amount,
      'status': 'done',
      'vendor_id': id,
      'currency': 'IQD',
      'product_name': 'تعديل إداري',
      'customer_name': 'admin',
      'customer_id': '',
      'order_id': '',
      'request_id': '',
      'payment_type': 'admin_adjustment',
      'payment_transaction_id': '',
      'product_id': '',
      'shipment_company_id': '',
      'shipment_company_name': '',
      'shipment_offer_id': '',
      'shipping_price': 0,
      'order_price': 0,
      'app_commission': 0,
      'commission_percent': 0,
      'created_at': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Maps provider id → alert value from `provider_min_wallet_allert`.
  Future<Map<String, num>> fetchAllProviderMinWalletAlerts() async {
    final snapshot = await _providerMinWalletAllert.get();
    final byId = <String, num>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final value = _parseNumericValue(data['value']);
      if (value == null) continue;
      final id = (data['id'] as String?)?.trim() ?? '';
      if (id.isNotEmpty) byId[id] = value;
      // Doc id may also be the provider uid (app creates with doc(providerId)).
      if (doc.id.trim().isNotEmpty) byId[doc.id.trim()] = value;
    }
    return byId;
  }

  Future<Map<String, num>> fetchAllUserMinWalletAlerts() async {
    final snapshot = await _userMinWalletAlert.get();
    final byEmail = <String, num>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final email = (data['user_email'] as String?)?.trim().toLowerCase() ?? '';
      final value = _parseNumericValue(data['value']);
      if (email.isEmpty || value == null) continue;
      byEmail[email] = value;
    }
    return byEmail;
  }

  Future<num?> fetchMinWalletAlert(String userEmail) async {
    final email = userEmail.trim();
    if (email.isEmpty) return null;

    final exact = await _userMinWalletAlert
        .where('user_email', isEqualTo: email)
        .limit(1)
        .get();
    if (exact.docs.isNotEmpty) {
      return _parseNumericValue(exact.docs.first.data()['value']);
    }

    final lower = email.toLowerCase();
    if (lower != email) {
      final lowerSnap = await _userMinWalletAlert
          .where('user_email', isEqualTo: lower)
          .limit(1)
          .get();
      if (lowerSnap.docs.isNotEmpty) {
        return _parseNumericValue(lowerSnap.docs.first.data()['value']);
      }
    }

    final all = await fetchAllUserMinWalletAlerts();
    return all[lower];
  }

  Future<void> upsertMinWalletAlert({
    required String userEmail,
    required num value,
  }) async {
    final email = userEmail.trim().toLowerCase();
    if (email.isEmpty) return;
    final storedValue = value % 1 == 0 ? value.toInt() : value;

    final exact = await _userMinWalletAlert
        .where('user_email', isEqualTo: email)
        .limit(1)
        .get();
    if (exact.docs.isNotEmpty) {
      await exact.docs.first.reference.update({
        'user_email': email,
        'value': storedValue,
      });
      return;
    }

    // Update legacy docs that stored mixed-case emails.
    final snapshot = await _userMinWalletAlert.get();
    for (final doc in snapshot.docs) {
      final existing =
          (doc.data()['user_email'] as String?)?.trim().toLowerCase() ?? '';
      if (existing == email) {
        await doc.reference.update({
          'user_email': email,
          'value': storedValue,
        });
        return;
      }
    }

    await _userMinWalletAlert.add({
      'user_email': email,
      'value': storedValue,
    });
  }

  num? _parseNumericValue(dynamic raw) {
    if (raw is num) return raw;
    if (raw is String) return num.tryParse(raw.replaceAll(',', '.'));
    return null;
  }

  Future<num?> fetchProviderMinWalletAlert({
    required String providerId,
    String? email,
  }) async {
    final id = providerId.trim();
    if (id.isNotEmpty) {
      final byId = await _providerMinWalletAllert
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (byId.docs.isNotEmpty) {
        return _parseNumericValue(byId.docs.first.data()['value']);
      }
    }

    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isEmpty) return null;
    final byEmail = await _providerMinWalletAllert
        .where('email', isEqualTo: trimmedEmail)
        .limit(1)
        .get();
    if (byEmail.docs.isEmpty) return null;
    return _parseNumericValue(byEmail.docs.first.data()['value']);
  }

  Future<void> upsertProviderMinWalletAlert({
    required String providerId,
    required String email,
    required num value,
  }) async {
    final id = providerId.trim();
    final trimmedEmail = email.trim();
    if (id.isEmpty || trimmedEmail.isEmpty) return;

    final payload = {
      'email': trimmedEmail,
      'id': id,
      'value': value.toDouble(),
    };

    final byId = await _providerMinWalletAllert
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    if (byId.docs.isNotEmpty) {
      await byId.docs.first.reference.update(payload);
      return;
    }

    final byEmail = await _providerMinWalletAllert
        .where('email', isEqualTo: trimmedEmail)
        .limit(1)
        .get();
    if (byEmail.docs.isNotEmpty) {
      await byEmail.docs.first.reference.update(payload);
      return;
    }

    await _providerMinWalletAllert.add(payload);
  }

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
