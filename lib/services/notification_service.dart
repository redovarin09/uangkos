import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:uang_kos/models/reminder_config.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Channel ───────────────────────────────────────────
  static const _channelId   = 'uangkos_reminder';
  static const _channelName = 'Pengingat Uang Kos';
  static const _channelDesc = 'Notifikasi pengingat pembayaran uang kos bulanan';

  // ── Notification IDs (fixed per offset) ───────────────
  static const _id7Days = 7;
  static const _id3Days = 3;
  static const _idOnDue = 1; // Hindari ID 0

  // ── Init ──────────────────────────────────────────────
  static Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Buat channel (wajib Android 8+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );
  }

  // ── Request Permissions (Android 13+) ─────────────────
  static Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  // ── Schedule All Active Reminders ─────────────────────
  static Future<void> scheduleReminders(ReminderConfig config) async {
    await cancelAll();
    if (!config.isEnabled) return;

    final now = DateTime.now();

    for (final offsetDays in config.activeDayOffsets) {
      final int id = _idForOffset(offsetDays);
      final DateTime scheduledDate = _nextNotifDate(
        dueDateDay:    config.dueDateDay,
        daysBeforeDue: offsetDays,
        now:           now,
      );

      await _scheduleOne(
        id:            id,
        title:         _buildTitle(offsetDays),
        body:          _buildBody(offsetDays, config.dueDateDay),
        scheduledDate: scheduledDate,
      );
    }
  }

  // ── Cancel ────────────────────────────────────────────
  static Future<void> cancelAll() => _plugin.cancelAll();

  // ── Private: schedule single notif ────────────────────
  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority:   Priority.high,
        icon:       '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Private: hitung tanggal notif berikutnya ──────────
  static DateTime _nextNotifDate({
    required int dueDateDay,
    required int daysBeforeDue,
    required DateTime now,
  }) {
    // Notif dikirim jam 09:00 pagi
    DateTime candidate = DateTime(
      now.year,
      now.month,
      dueDateDay,
      9, 0, 0,
    ).subtract(Duration(days: daysBeforeDue));

    // Kalau sudah lewat → geser ke bulan depan
    if (!candidate.isAfter(now)) {
      final int nextMonth = now.month == 12 ? 1 : now.month + 1;
      final int nextYear  = now.month == 12 ? now.year + 1 : now.year;
      candidate = DateTime(
        nextYear,
        nextMonth,
        dueDateDay,
        9, 0, 0,
      ).subtract(Duration(days: daysBeforeDue));
    }

    return candidate;
  }

  static int _idForOffset(int offsetDays) {
    if (offsetDays == 7) return _id7Days;
    if (offsetDays == 3) return _id3Days;
    return _idOnDue;
  }

  static String _buildTitle(int offsetDays) {
    if (offsetDays == 0) return '🔔 Hari ini jatuh tempo!';
    return '⏰ $offsetDays hari lagi jatuh tempo';
  }

  static String _buildBody(int offsetDays, int dueDay) {
    if (offsetDays == 0) {
      return 'Segera bayar uang kos bulan ini (tanggal $dueDay).';
    }
    return 'Uang kos jatuh tempo tanggal $dueDay. Jangan lupa siapkan pembayaran!';
  }
}
