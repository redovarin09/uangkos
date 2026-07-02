import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/providers/payment_provider.dart';
import 'package:uang_kos/providers/reminder_provider.dart';
import 'package:uang_kos/services/backup_service.dart';

class DataManagementCard extends ConsumerWidget {
  const DataManagementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.backup_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('Backup & Restore', style: tt.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Simpan atau pulihkan seluruh data pembayaran & pengaturan.',
            style: tt.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _backup(context),
                  icon: const Icon(Icons.upload_outlined, size: 18),
                  label: const Text('Backup'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _restore(context, ref),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Restore'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Backup ────────────────────────────────────────────
  Future<void> _backup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await BackupService.exportBackup();
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup data Uang Kos',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal backup: $e')));
    }
  }

  // ── Restore ───────────────────────────────────────────
  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    try {
      final preview = await BackupService.readBackupFile(File(path));

      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pulihkan Data?'),
          content: Text(
            'File berisi ${preview.paymentCount} data pembayaran.\n\n'
            '⚠️ Semua data saat ini akan DIHAPUS dan diganti dengan '
            'data dari file ini. Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Pulihkan'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await BackupService.restoreFromPreview(preview);
      ref.invalidate(paymentProvider);
      ref.invalidate(reminderProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Data berhasil dipulihkan!')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal restore: $e')));
    }
  }
}
