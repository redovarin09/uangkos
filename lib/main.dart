import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/app.dart';
import 'package:uang_kos/services/database_service.dart';
import 'package:uang_kos/services/notification_service.dart';
import 'package:uang_kos/services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Init locale Indonesia
  await initializeDateFormatting('id_ID', null);

  // 1. Init Hive + register adapter
  await DatabaseService.init();

  // 2. Init notification channel
  await NotificationService.init();

  // 3. Request permission (Android 13+)
  await NotificationService.requestPermission();

  // 4. Load config & schedule reminder yang tersimpan
  final config = await ReminderService.load();
  await NotificationService.scheduleReminders(config);

  runApp(const ProviderScope(child: UangKosApp()));
}
