import 'package:hive_ce/hive.dart';
import 'package:uang_kos/models/payment.dart';
import 'package:uang_kos/services/database_service.dart';

class PaymentService {
  Box<Payment> get _box => DatabaseService.paymentBox;

  // ── CREATE ────────────────────────────────────────────
  Future<void> add(Payment payment) => _box.add(payment);

  // ── UPDATE ────────────────────────────────────────────
  /// Payment extends HiveObject — .save() langsung update di box
  Future<void> update(Payment payment) => payment.save();

  // ── DELETE ────────────────────────────────────────────
  Future<void> delete(Payment payment) => payment.delete();

  // ── READ ──────────────────────────────────────────────
  List<Payment> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }

  List<Payment> getByYear(int year) {
    return _box.values
        .where((p) => p.periodMonth.year == year)
        .toList()
      ..sort((a, b) => b.periodMonth.compareTo(a.periodMonth));
  }

  Payment? getForMonth(int month, int year) {
    try {
      return _box.values.firstWhere((p) => p.isForMonth(month, year));
    } catch (_) {
      return null;
    }
  }

  // ── AGREGAT ───────────────────────────────────────────
  double totalForYear(int year) =>
      getByYear(year).fold(0.0, (sum, p) => sum + p.amount);

  int paidMonthsCount(int year) => getByYear(year).length;

  // ── REACTIVE ──────────────────────────────────────────
  /// Stream ini trigger rebuild Riverpod saat box berubah
  Stream<BoxEvent> get changes => DatabaseService.paymentBox.watch();
}
