import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/services/database_service.dart';
import 'package:uang_kos/services/notification_service.dart';
import 'package:uang_kos/services/reminder_service.dart';
import 'package:uang_kos/ui/shared/app_scaffold.dart';

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  String? _errorMsg;
  String? _stackMsg;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      // ── Wajib: kalau gagal, app benar-benar tidak bisa jalan ──
      await initializeDateFormatting('id_ID', null);
      await DatabaseService.init();
      await NotificationService.init();

      // ── Opsional: kalau gagal, jangan blokir boot ─────────────
      try {
        await NotificationService.requestPermission();
      } catch (_) {
        // Permission ditolak/tidak tersedia di device — tidak fatal
      }

      try {
        final config = await ReminderService.load();
        await NotificationService.scheduleReminders(config);
      } catch (_) {
        // Gagal jadwal notif — tidak fatal, bisa diulang dari Settings
      }

      if (mounted) setState(() => _ready = true);
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _stackMsg = st.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Gagal memuat aplikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMsg!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _stackMsg ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return const AppScaffold();
  }
}
