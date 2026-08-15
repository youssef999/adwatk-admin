/// Display labels for Firestore status values.
class StatusLabelUtils {
  StatusLabelUtils._();

  /// `completed` and `delivery_completed` are treated as the same status.
  static bool isCompleted(String status) {
    final key = status.trim().toLowerCase();
    return key == 'completed' || key == 'delivery_completed' || key == 'done';
  }

  /// Canonical value for filter chips (merge delivery_completed → completed).
  static String canonicalizeForFilter(String status) {
    if (isCompleted(status)) return 'completed';
    return status.trim();
  }

  /// Filter match: completed filter includes delivery_completed and vice versa.
  static bool matchesFilter(String itemStatus, String filter) {
    if (filter == 'all') return true;
    if (isCompleted(filter)) return isCompleted(itemStatus);
    return itemStatus == filter;
  }

  static String labelAr(String status) {
    final key = status.trim().toLowerCase();
    if (key.isEmpty) return '—';

    switch (key) {
      case 'all':
        return 'الكل';
      case 'completed':
      case 'delivery_completed':
      case 'done':
        return 'مكتمل';
      case 'pending':
        return 'قيد الانتظار';
      case 'received':
        return 'تم الاستلام';
      case 'cancelled':
      case 'canceled':
        return 'ملغي';
      case 'rejected':
        return 'مرفوض';
      case 'accepted':
        return 'مقبول';
      case 'delivered':
        return 'تم التسليم';
      case 'active':
        return 'نشط';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'new':
        return 'جديد';
      case 'sent':
        return 'تم الإرسال';
      case 'request_sent':
        return 'بانتظار إرسال الأرباح';
      case 'waiting':
        return 'بانتظار';
      case 'failed':
        return 'فشل';
      case 'open':
        return 'مفتوح';
      case 'closed':
        return 'مغلق';
      case 'paid':
        return 'مدفوع';
      case 'unpaid':
        return 'غير مدفوع';
      default:
        return status.trim();
    }
  }
}
