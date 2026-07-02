import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/models/payment.dart';
import 'package:uang_kos/providers/payment_provider.dart';
import 'package:uang_kos/services/pdf_export_service.dart';
import 'package:uang_kos/ui/screens/history/widgets/payment_list_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments     = ref.watch(filteredPaymentsProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final tt           = Theme.of(context).textTheme;
    final now          = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: payments.isEmpty
                ? null
                : () => _exportPdf(context, payments, selectedYear),
          ),
          // ── Year filter dropdown ───────────────
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedYear,
                items: List.generate(5, (i) => now.year - i)
                    .map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text('$y', style: tt.labelLarge),
                      ),
                    )
                    .toList(),
                onChanged: (y) {
                  if (y != null) {
                    ref.read(selectedYearProvider.notifier).state = y;
                  }
                },
              ),
            ),
          ),
        ],
      ),

      body: payments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  AppStrings.labelBelumAdaData,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) =>
                  PaymentListTile(payment: payments[i]),
            ),
    );
  }
}

// ── Export PDF Handler ─────────────────────────────────────────────
Future<void> _exportPdf(
  BuildContext context,
  List<Payment> payments,
  int year,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final file = await PdfExportService.generateYearlyReport(
      payments: payments,
      year: year,
    );
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Laporan Pembayaran Uang Kos Tahun $year',
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Gagal export PDF: $e')),
    );
  }
}
