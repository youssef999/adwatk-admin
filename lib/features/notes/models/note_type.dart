/// Note type for `noti_notes_banner.type` (Firestore value).
class NoteType {
  NoteType._();

  static const String noti = 'noti';
  static const String alert = 'alert';
  static const String offer = 'offer';

  static const List<String> values = [noti, alert, offer];

  static String labelAr(String value) {
    switch (value.trim().toLowerCase()) {
      case noti:
        return 'إشعار';
      case alert:
        return 'تحذير';
      case offer:
        return 'عرض';
      default:
        return value.trim().isEmpty ? '—' : value.trim();
    }
  }

  static String normalize(String? raw, {String fallback = noti}) {
    final key = (raw ?? '').trim().toLowerCase();
    if (values.contains(key)) return key;
    return fallback;
  }
}
