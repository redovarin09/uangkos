import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/core/theme/app_theme.dart';
import 'package:uang_kos/providers/theme_provider.dart';
import 'package:uang_kos/ui/shared/app_scaffold.dart';

class UangKosApp extends ConsumerWidget {
  const UangKosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('id', 'ID'),
      home: const AppScaffold(),
    );
  }
}
