import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/models/payment.dart';
import 'package:uang_kos/services/payment_service.dart';

// ── Service instance ──────────────────────────────────────────────
final paymentServiceProvider =
    Provider<PaymentService>((_) => PaymentService());

// ── Year filter (History tab) ─────────────────────────────────────
final selectedYearProvider =
    StateProvider<int>((_) => DateTime.now().year);

// ── Main CRUD notifier ────────────────────────────────────────────
class PaymentNotifier extends StateNotifier<List<Payment>> {
  final PaymentService _service;

  PaymentNotifier(this._service) : super(_service.getAll());

  Future<void> add(Payment payment) async {
    await _service.add(payment);
    _refresh();
  }

  Future<void> update(Payment payment) async {
    await _service.update(payment);
    _refresh();
  }

  Future<void> delete(Payment payment) async {
    await _service.delete(payment);
    _refresh();
  }

  void _refresh() => state = _service.getAll();
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, List<Payment>>((ref) {
  return PaymentNotifier(ref.read(paymentServiceProvider));
});

// ── Filtered by selected year ─────────────────────────────────────
final filteredPaymentsProvider = Provider<List<Payment>>((ref) {
  final all  = ref.watch(paymentProvider);
  final year = ref.watch(selectedYearProvider);
  return all.where((p) => p.periodMonth.year == year).toList()
    ..sort((a, b) => b.periodMonth.compareTo(a.periodMonth));
});

// ── Dashboard: bulan ini ──────────────────────────────────────────
final currentMonthPaymentProvider = Provider<Payment?>((ref) {
  final all = ref.watch(paymentProvider);
  final now = DateTime.now();
  try {
    return all.firstWhere((p) => p.isForMonth(now.month, now.year));
  } catch (_) {
    return null;
  }
});

// ── Dashboard: total & jumlah bulan tahun ini ────────────────────
final yearlyTotalProvider = Provider<double>((ref) {
  final all  = ref.watch(paymentProvider);
  final year = DateTime.now().year;
  return all
      .where((p) => p.periodMonth.year == year)
      .fold(0.0, (sum, p) => sum + p.amount);
});

final paidMonthsCountProvider = Provider<int>((ref) {
  final all  = ref.watch(paymentProvider);
  final year = DateTime.now().year;
  return all.where((p) => p.periodMonth.year == year).length;
});
