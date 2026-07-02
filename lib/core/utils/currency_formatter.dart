import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static final _fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Rp 1.500.000
  static String format(double amount) => _fmt.format(amount);

  /// Rp 1,5jt / Rp 500rb — untuk ruang terbatas
  static String compact(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return format(amount);
  }
}
