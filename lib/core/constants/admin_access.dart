class AdminAccess {
  AdminAccess._();

  /// Must stay in sync with `isAdmin()` in Firestore & Storage security rules.
  static const Set<String> emails = {
    'admin2026@adwatk.com',
  };

  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    return emails.contains(email.trim().toLowerCase());
  }
}
