class TripConfig {
  TripConfig._();

  static const String tripId = 'viaje-g62-7';
  static const String name = 'Escapada Eje Cafetero';
  static const String currency = 'COP';
  static const int totalBudget = 2000000;
  static const int slotDurationHours = 2;
  static const List<int> slotStartHours = [8, 10, 12, 14, 16, 18];
  static final DateTime startDate = DateTime(2027, 2, 1);
  static final DateTime endDate = DateTime(2027, 2, 5);

  static List<DateTime> get days {
    final result = <DateTime>[];
    var day = DateTime(startDate.year, startDate.month, startDate.day);
    while (!day.isAfter(endDate)) {
      result.add(day);
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return result;
  }

  static DateTime slotStart(DateTime day, int hour) {
    return DateTime(day.year, day.month, day.day, hour);
  }

  static DateTime slotEnd(DateTime start) {
    return start.add(const Duration(hours: slotDurationHours));
  }

  static String slotId(DateTime start) {
    final month = start.month.toString().padLeft(2, '0');
    final day = start.day.toString().padLeft(2, '0');
    final hour = start.hour.toString().padLeft(2, '0');
    return '${start.year}$month${day}_$hour';
  }

  static bool isTripDay(DateTime d) {
    final key = _dayKey(d);
    return key >= _dayKey(startDate) && key <= _dayKey(endDate);
  }

  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
}
