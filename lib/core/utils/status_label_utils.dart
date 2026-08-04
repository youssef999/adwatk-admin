/// Display labels for Firestore status values.
/// Filtering/search must keep using the raw [status] string.
class StatusLabelUtils {
  StatusLabelUtils._();

  static String labelAr(String status) {
    final key = status.trim().toLowerCase();
    if (key.isEmpty) return '—';

    switch (key) {
      case 'all':
        return 'الكل';
      case 'completed':
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
      case 'done':
        return 'مكتمل';
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
