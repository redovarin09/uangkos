import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uang_kos/core/utils/currency_formatter.dart';
import 'package:uang_kos/core/utils/date_formatter.dart';
import 'package:uang_kos/models/payment.dart';

class PdfExportService {
  /// Generate laporan PDF pembayaran untuk satu tahun.
  /// Returns File PDF yang tersimpan di temp directory.
  static Future<File> generateYearlyReport({
    required List<Payment> payments,
    required int year,
  }) async {
    final doc = pw.Document();

    final sorted = [...payments]
      ..sort((a, b) => a.periodMonth.compareTo(b.periodMonth));

    final double total = sorted.fold(0.0, (sum, p) => sum + p.amount);
    final int paidMonths = sorted.length;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(year),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummary(total, paidMonths),
          pw.SizedBox(height: 20),
          _buildTable(sorted),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/laporan_uangkos_$year.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  // ── Header ────────────────────────────────────────────
  static pw.Widget _buildHeader(int year) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'UANG KOS',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Laporan Pembayaran Tahun $year',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  // ── Summary ───────────────────────────────────────────
  static pw.Widget _buildSummary(double total, int paidMonths) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryBox('Total Dibayar', CurrencyFormatter.format(total)),
        _summaryBox('Bulan Lunas', '$paidMonths dari 12 bulan'),
      ],
    );
  }

  static pw.Widget _summaryBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      width: 240,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Table ─────────────────────────────────────────────
  static pw.Widget _buildTable(List<Payment> payments) {
    if (payments.isEmpty) {
      return pw.Center(
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(top: 40),
          child: pw.Text(
            'Belum ada data pembayaran untuk tahun ini.',
            style: const pw.TextStyle(color: PdfColors.grey600),
          ),
        ),
      );
    }

    return pw.TableHelper.fromTextArray(
      headers: ['No', 'Periode', 'Tgl Bayar', 'Nominal', 'Catatan'],
      data: List.generate(payments.length, (i) {
        final p = payments[i];
        return [
          '${i + 1}',
          DateFormatter.shortMonth(p.periodMonth),
          DateFormatter.dayMonth(p.paymentDate),
          CurrencyFormatter.compact(p.amount),
          p.note ?? '-',
        ];
      }),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        0: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    );
  }

  // ── Footer ────────────────────────────────────────────
  static pw.Widget _buildFooter(pw.Context context) {
    final now = DateTime.now();
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Dicetak: ${DateFormatter.dayMonthYear(now)}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }
}
