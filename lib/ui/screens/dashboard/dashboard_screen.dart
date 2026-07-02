import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/utils/date_formatter.dart';
import 'package:uang_kos/models/payment.dart';
import 'package:uang_kos/providers/payment_provider.dart';
import 'package:uang_kos/providers/reminder_provider.dart';
import 'package:uang_kos/providers/theme_provider.dart';
import 'package:uang_kos/ui/screens/dashboard/widgets/countdown_card.dart';
import 'package:uang_kos/ui/screens/dashboard/widgets/status_card.dart';
import 'package:uang_kos/ui/screens/dashboard/widgets/yearly_summary_card.dart';
import 'package:uang_kos/ui/screens/history/widgets/payment_form_sheet.dart';
import 'package:uang_kos/ui/shared/custom_fab.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now            = DateTime.now();
    final currentPayment = ref.watch(currentMonthPaymentProvider);
    final yearlyTotal    = ref.watch(yearlyTotalProvider);
    final paidCount      = ref.watch(paidMonthsCountProvider);
    final reminderAsync  = ref.watch(reminderProvider);

    final int dueDateDay = reminderAsync.when(
      data:    (c) => c.dueDateDay,
      loading: () => 25,
      error:   (_, __) => 25,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.monthYear(now)),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Lihat Riwayat',
            onPressed: () =>
                ref.read(activeTabProvider.notifier).state = 1,
          ),
        ],
      ),

      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(paymentProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            StatusCard(
              payment: currentPayment,
              onTap:   () => _openForm(context, ref, existing: currentPayment),
            ),
            const SizedBox(height: 12),
            CountdownCard(dueDateDay: dueDateDay),
            const SizedBox(height: 12),
            YearlySummaryCard(
              totalAmount: yearlyTotal,
              paidMonths:  paidCount,
              year:        now.year,
            ),
          ],
        ),
      ),

      floatingActionButton: CustomFab(
        onPressed: () => _openForm(context, ref),
      ),
    );
  }

  void _openForm(
    BuildContext context,
    WidgetRef ref, {
    Payment? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentFormSheet(existing: existing),
    );
  }
}
