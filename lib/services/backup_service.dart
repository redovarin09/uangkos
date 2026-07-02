import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uang_kos/models/payment.dart';
import 'package:uang_kos/models/reminder_config.dart';
import 'package:uang_kos/services/database_service.dart';
import 'package:uang_kos/services/payment_service.dart';
import 'package:uang_kos/services/reminder_service.dart';

class BackupException implements Exception {
  final String message;
  BackupException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  static const int _formatVersion = 1;

  // ── EXPORT ──────────────────────────────────────────────
  /// Generate file JSON backup seluruh data (payments + config).
  /// Returns File yang tersimpan di temp directory.
  static Future<File> exportBackup() async {
    final payments = PaymentService().getAll();
    final config   = await ReminderService.load();

    final data = {
      'version': _formatVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'payments': payments.map(_paymentToJson).toList(),
      'reminderConfig': _configToJson(config),
    };

    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final fileName =
        'backup_uangkos_${now.year}${_pad(now.month)}${_pad(now.day)}.json';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    return file;
  }

  // ── IMPORT / RESTORE ────────────────────────────────────
  /// Baca & validasi file JSON, return summary untuk konfirmasi user
  /// sebelum benar-benar menimpa data.
  static Future<BackupPreview> readBackupFile(File file) async {
    late final Map<String, dynamic> data;

    try {
      final content = await file.readAsString();
      data = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('File bukan format JSON yang valid.');
    }

    if (data['version'] == null || data['payments'] == null) {
      throw BackupException('Struktur file backup tidak dikenali.');
    }

    final List<dynamic> rawPayments = data['payments'] as List<dynamic>;

    return BackupPreview(
      paymentCount: rawPayments.length,
      exportDate: data['exportDate'] as String?,
      rawData: data,
    );
  }

  /// Eksekusi restore — WAJIB dipanggil setelah user konfirmasi.
  /// Menghapus seluruh data lama lalu insert dari backup.
  static Future<void> restoreFromPreview(BackupPreview preview) async {
    final data = preview.rawData;

    final List<dynamic> rawPayments = data['payments'] as List<dynamic>;
    final payments = rawPayments
        .map((e) => _paymentFromJson(e as Map<String, dynamic>))
        .toList();

    // Clear semua data lama
    await DatabaseService.paymentBox.clear();

    // Insert data baru
    for (final p in payments) {
      await DatabaseService.paymentBox.add(p);
    }

    // Restore reminder config kalau ada
    final rawConfig = data['reminderConfig'] as Map<String, dynamic>?;
    if (rawConfig != null) {
      await ReminderService.save(_configFromJson(rawConfig));
    }
  }

  // ── Helpers: Payment <-> JSON ────────────────────────────
  static Map<String, dynamic> _paymentToJson(Payment p) => {
        'amount': p.amount,
        'paymentDate': p.paymentDate.toIso8601String(),
        'periodMonth': p.periodMonth.toIso8601String(),
        'note': p.note,
      };

  static Payment _paymentFromJson(Map<String, dynamic> json) => Payment(
        amount: (json['amount'] as num).toDouble(),
        paymentDate: DateTime.parse(json['paymentDate'] as String),
        periodMonth: DateTime.parse(json['periodMonth'] as String),
        note: json['note'] as String?,
      );

  // ── Helpers: ReminderConfig <-> JSON ─────────────────────
  static Map<String, dynamic> _configToJson(ReminderConfig c) => {
        'dueDateDay': c.dueDateDay,
        'notify7DaysBefore': c.notify7DaysBefore,
        'notify3DaysBefore': c.notify3DaysBefore,
        'notifyOnDueDate': c.notifyOnDueDate,
        'isEnabled': c.isEnabled,
      };

  static ReminderConfig _configFromJson(Map<String, dynamic> json) =>
      ReminderConfig(
        dueDateDay: json['dueDateDay'] as int? ?? 25,
        notify7DaysBefore: json['notify7DaysBefore'] as bool? ?? false,
        notify3DaysBefore: json['notify3DaysBefore'] as bool? ?? true,
        notifyOnDueDate: json['notifyOnDueDate'] as bool? ?? true,
        isEnabled: json['isEnabled'] as bool? ?? true,
      );

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

// ── Preview Model ───────────────────────────────────────────
/// Ringkasan isi backup sebelum dieksekusi — dipakai untuk
/// tampilkan dialog konfirmasi ke user.
class BackupPreview {
  final int paymentCount;
  final String? exportDate;
  final Map<String, dynamic> rawData;

  BackupPreview({
    required this.paymentCount,
    required this.exportDate,
    required this.rawData,
  });
}
