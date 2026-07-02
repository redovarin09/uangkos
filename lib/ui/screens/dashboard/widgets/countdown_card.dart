import 'package:flutter/material.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/core/utils/date_formatter.dart';

class CountdownCard extends StatelessWidget {
  final int dueDateDay; // Hari jatuh tempo (1–28)

  const CountdownCard({super.key, required this.dueDateDay});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final now      = DateTime.now();
    final dueDate  = _nextDueDate(now, dueDateDay);
    final days     = DateFormatter.daysUntil(dueDate);

    final Color accent  = _accentColor(days);
    final String label  = _label(days);
    final IconData icon = _icon(days);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          // ── Countdown number ──────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.labelJatuhTempo,
                style: tt.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    days.abs().toString(),
                    style: tt.displayLarge?.copyWith(
                      color: accent,
                      fontSize: 52,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      days < 0
                          ? '${AppStrings.labelHari}\n${AppStrings.labelTerlambat}'
                          : AppStrings.labelHariLagi,
                      style: tt.bodyMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: tt.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),

          const Spacer(),

          // ── Icon ──────────────────────────────
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────
  DateTime _nextDueDate(DateTime now, int day) {
    DateTime candidate = DateTime(now.year, now.month, day);
    if (!candidate.isAfter(
      DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1)),
    )) {
      // Sudah lewat bulan ini → bulan depan
      final next = now.month == 12 ? 1 : now.month + 1;
      final year = now.month == 12 ? now.year + 1 : now.year;
      candidate  = DateTime(year, next, day);
    }
    return candidate;
  }

  Color _accentColor(int days) {
    if (days < 0) return AppColors.danger;
    if (days <= 3) return AppColors.warning;
    return AppColors.primary;
  }

  String _label(int days) {
    final now     = DateTime.now();
    final due     = _nextDueDate(now, dueDateDay);
    final dateStr = DateFormatter.dayMonthYear(due);
    if (days == 0) return AppStrings.labelHariIni;
    if (days < 0)  return 'Sejak $dateStr';
    return dateStr;
  }

  IconData _icon(int days) {
    if (days < 0)  return Icons.warning_amber_rounded;
    if (days <= 3) return Icons.timer_outlined;
    return Icons.calendar_today_rounded;
  }
}
