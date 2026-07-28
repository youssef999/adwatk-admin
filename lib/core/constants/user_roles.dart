class UserRoles {
  UserRoles._();

  static const String customer = 'customer';
  static const String worker = 'worker';
  static const String testWorker = 'test_worker';

  static const List<String> vendorRoles = [worker, testWorker];

  static bool isVendor(String role) => vendorRoles.contains(role);
  static bool isCustomer(String role) => role == customer;
}
