/// Normalizes Firebase Storage / network image URLs used across the app.
///
/// Expected download URL shape:
/// `https://firebasestorage.googleapis.com/v0/b/<bucket>.firebasestorage.app/o/<path>?alt=media&token=...`
class StorageUrl {
  StorageUrl._();

  static const _firebaseHost = 'firebasestorage.googleapis.com';
  static const _gcsHost = 'storage.googleapis.com';

  /// Returns a trimmed usable URL, or `null` when empty / invalid.
  static String? normalize(String? raw) {
    if (raw == null) return null;

    var url = raw.trim();
    if (url.isEmpty) return null;

    // Strip accidental wrapping quotes from copied Firestore values.
    if ((url.startsWith('"') && url.endsWith('"')) ||
        (url.startsWith("'") && url.endsWith("'"))) {
      url = url.substring(1, url.length - 1).trim();
      if (url.isEmpty) return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.scheme == 'gs') {
      // gs:// URLs need async resolution via FirebaseStorage; callers should
      // store download URLs. Treat as unusable for direct Image.network.
      return null;
    }

    if (uri.hasScheme && uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }

    // Relative storage object path (e.g. sale_parts/uid/file.jpg) — not a URL.
    if (!uri.hasScheme) return null;

    return url;
  }

  static bool isUsable(String? raw) => normalize(raw) != null;

  static bool isFirebaseStorage(String? raw) {
    final url = normalize(raw);
    if (url == null) return false;
    final host = Uri.tryParse(url)?.host ?? '';
    return host == _firebaseHost || host == _gcsHost;
  }
}
