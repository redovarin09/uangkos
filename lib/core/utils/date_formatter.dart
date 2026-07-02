import 'package:intl/intl.dart';

abstract class DateFormatter {
  static final _monthYear    = DateFormat('MMMM yyyy', 'id_ID');
  static final _dayMonth     = DateFormat('d MMMM', 'id_ID');
  static final _dayMonthYear = DateFormat('d MMMM yyyy', 'id_ID');
  static final _shortMonth   = DateFormat('MMM yyyy', 'id_ID');

  /// "Juli 2026"
  static String monthYear(DateTime d) => _monthYear.format(d);

  /// "25 Juli"
  static String dayMonth(DateTime d) => _dayMonth.format(d);

  /// "25 Juli 2026"
  static String dayMonthYear(DateTime d) => _dayMonthYear.format(d);

  /// "Jul 2026" — untuk label chip/filter
  static String shortMonth(DateTime d) => _shortMonth.format(d);

  /// Hitung selisih hari dari sekarang ke targetDate
  static int daysUntil(DateTime target) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final t     = DateTime(target.year, target.month, target.day);
    return t.difference(today).inDays;
  }
}
