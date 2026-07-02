import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/providers/theme_provider.dart';
import 'package:uang_kos/ui/screens/dashboard/dashboard_screen.dart';
import 'package:uang_kos/ui/screens/history/history_screen.dart';
import 'package:uang_kos/ui/screens/reminder/reminder_screen.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    HistoryScreen(),
    ReminderScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(activeTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(activeTabProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: AppStrings.navDashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: AppStrings.navHistory,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications_rounded),
            label: AppStrings.navReminder,
          ),
        ],
      ),
    );
  }
}
