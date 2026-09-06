/// Audience target for `noti_notes_banner.to` (Firestore value).
class NoteAudience {
  NoteAudience._();

  static const String clients = 'clients';
  static const String vendors = 'vendors';
  static const String shipments = 'shipments';

  static const List<String> values = [clients, vendors, shipments];

  static String labelAr(String value) {
    switch (value.trim().toLowerCase()) {
      case clients:
        return 'العملاء';
      case vendors:
        return 'التجار او المحلات';
      case shipments:
        return 'الشحن';
      default:
        return value.trim().isEmpty ? '—' : value.trim();
    }
  }

  static String normalize(String? raw, {String fallback = clients}) {
    final key = (raw ?? '').trim().toLowerCase();
    if (values.contains(key)) return key;
    return fallback;
  }
}
