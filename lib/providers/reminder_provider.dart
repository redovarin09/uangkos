import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/models/reminder_config.dart';
import 'package:uang_kos/services/notification_service.dart';
import 'package:uang_kos/services/reminder_service.dart';

class ReminderNotifier extends AsyncNotifier<ReminderConfig> {
  @override
  Future<ReminderConfig> build() => ReminderService.load();

  /// Simpan config dulu & update UI segera.
  /// Scheduling notifikasi bersifat best-effort — kalau gagal
  /// (mis. permission exact alarm ditolak), config tetap tersimpan.
  Future<void> save(ReminderConfig config) async {
    await ReminderService.save(config);
    state = AsyncData(config);

    try {
      await NotificationService.scheduleReminders(config);
    } catch (_) {
      // Gagal jadwalkan notifikasi — tidak fatal, config sudah aman
    }
  }

  Future<void> toggleEnabled(bool value) async {
    final current = state.value;
    if (current == null) return;
    await save(current.copyWith(isEnabled: value));
  }
}

final reminderProvider =
    AsyncNotifierProvider<ReminderNotifier, ReminderConfig>(
  ReminderNotifier.new,
);
