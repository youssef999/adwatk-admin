enum ProfitPeriod { day, week, month, year }

extension ProfitPeriodX on ProfitPeriod {
  String get labelAr {
    switch (this) {
      case ProfitPeriod.day:
        return 'يوم';
      case ProfitPeriod.week:
        return 'أسبوع';
      case ProfitPeriod.month:
        return '٣٠ يوم';
      case ProfitPeriod.year:
        return 'سنة';
    }
  }

  /// Start of the selected period in local time.
  /// [ProfitPeriod.month] = rolling last 30 days (not calendar month).
  DateTime startOf(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case ProfitPeriod.day:
        return today;
      case ProfitPeriod.week:
        // Week starts Saturday (common MENA calendar).
        final daysFromSaturday = (now.weekday + 1) % 7;
        return today.subtract(Duration(days: daysFromSaturday));
      case ProfitPeriod.month:
        return today.subtract(const Duration(days: 29));
      case ProfitPeriod.year:
        return DateTime(now.year, 1, 1);
    }
  }
}
