import 'package:shared_preferences/shared_preferences.dart';
import 'package:uang_kos/models/reminder_config.dart';

class ReminderService {
  // ── Keys ──────────────────────────────────────────────
  static const _kDueDay   = 'cfg_due_day';
  static const _k7Days    = 'cfg_notify_7';
  static const _k3Days    = 'cfg_notify_3';
  static const _kOnDue    = 'cfg_notify_0';
  static const _kEnabled  = 'cfg_enabled';

  // ── Load ──────────────────────────────────────────────
  static Future<ReminderConfig> load() async {
    final p = await SharedPreferences.getInstance();
    return ReminderConfig(
      dueDateDay:        p.getInt(_kDueDay)    ?? 25,
      notify7DaysBefore: p.getBool(_k7Days)    ?? false,
      notify3DaysBefore: p.getBool(_k3Days)    ?? true,
      notifyOnDueDate:   p.getBool(_kOnDue)    ?? true,
      isEnabled:         p.getBool(_kEnabled)  ?? true,
    );
  }

  // ── Save ──────────────────────────────────────────────
  static Future<void> save(ReminderConfig config) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setInt(_kDueDay,  config.dueDateDay),
      p.setBool(_k7Days,  config.notify7DaysBefore),
      p.setBool(_k3Days,  config.notify3DaysBefore),
      p.setBool(_kOnDue,  config.notifyOnDueDate),
      p.setBool(_kEnabled, config.isEnabled),
    ]);
  }
}
