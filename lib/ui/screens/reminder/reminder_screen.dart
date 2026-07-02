import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/models/reminder_config.dart';
import 'package:uang_kos/providers/reminder_provider.dart';
import 'package:uang_kos/providers/theme_provider.dart';
import 'package:uang_kos/ui/screens/reminder/widgets/reminder_toggle_card.dart';
import 'package:uang_kos/ui/screens/reminder/widgets/data_management_card.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt           = Theme.of(context).textTheme;
    final cs           = Theme.of(context).colorScheme;
    final reminderAsync = ref.watch(reminderProvider);
    final themeMode    = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.titleReminder)),
      body: reminderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data:    (config) => _buildContent(context, ref, config, themeMode, tt, cs),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ReminderConfig config,
    ThemeMode themeMode,
    TextTheme tt,
    ColorScheme cs,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [

        // ── Section: Jatuh Tempo ─────────────────
        _SectionLabel(label: AppStrings.labelTglJatuhTempo, tt: tt),
        const SizedBox(height: 8),
        _DueDatePicker(
          value: config.dueDateDay,
          onChanged: (d) => ref
              .read(reminderProvider.notifier)
              .save(config.copyWith(dueDateDay: d)),
        ),

        const SizedBox(height: 20),

        // ── Section: Notifikasi ──────────────────
        Row(
          children: [
            _SectionLabel(label: AppStrings.labelNotifHeader, tt: tt),
            const Spacer(),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: config.isEnabled,
                onChanged: (v) => ref
                    .read(reminderProvider.notifier)
                    .toggleEnabled(v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ReminderToggleCard(
          icon: Icons.notifications_outlined,
          label: AppStrings.label7Hari,
          subtitle: '7 hari sebelum tanggal ${config.dueDateDay}',
          value: config.notify7DaysBefore && config.isEnabled,
          onChanged: config.isEnabled
              ? (v) => ref
                  .read(reminderProvider.notifier)
                  .save(config.copyWith(notify7DaysBefore: v))
              : (_) {},
        ),
        const SizedBox(height: 8),
        ReminderToggleCard(
          icon: Icons.notifications_active_outlined,
          label: AppStrings.label3Hari,
          subtitle: '3 hari sebelum tanggal ${config.dueDateDay}',
          value: config.notify3DaysBefore && config.isEnabled,
          onChanged: config.isEnabled
              ? (v) => ref
                  .read(reminderProvider.notifier)
                  .save(config.copyWith(notify3DaysBefore: v))
              : (_) {},
        ),
        const SizedBox(height: 8),
        ReminderToggleCard(
          icon: Icons.alarm_on_rounded,
          label: AppStrings.labelHariH,
          subtitle: 'Tepat tanggal ${config.dueDateDay} setiap bulan',
          value: config.notifyOnDueDate && config.isEnabled,
          onChanged: config.isEnabled
              ? (v) => ref
                  .read(reminderProvider.notifier)
                  .save(config.copyWith(notifyOnDueDate: v))
              : (_) {},
        ),

        const SizedBox(height: 24),
        Divider(color: cs.outline),
        const SizedBox(height: 16),

        // ── Section: Tema ────────────────────────
        _SectionLabel(label: AppStrings.labelTema, tt: tt),
        const SizedBox(height: 8),
        _ThemeSelector(
          current: themeMode,
          onChanged: (m) =>
              ref.read(themeProvider.notifier).setTheme(m),
        ),

        const SizedBox(height: 24),
        Divider(color: cs.outline),
        const SizedBox(height: 16),

        // ── Section: Data ─────────────────────────
        _SectionLabel(label: 'Data', tt: tt),
        const SizedBox(height: 8),
        const DataManagementCard(),
      ],
    );
  }
}

// ── Due Date Picker ──────────────────────────────────────────────
class _DueDatePicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _DueDatePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '${AppStrings.labelSetiapBulan} $value',
            style: tt.bodyLarge,
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                color: AppColors.primary,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: tt.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: value < 28 ? () => onChanged(value + 1) : null,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Theme Selector ───────────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final options = [
      (ThemeMode.light,  Icons.light_mode_rounded,  AppStrings.labelTemaLight),
      (ThemeMode.dark,   Icons.dark_mode_rounded,   AppStrings.labelTemaDark),
      (ThemeMode.system, Icons.brightness_auto_rounded, AppStrings.labelTemaSystem),
    ];

    return Row(
      children: options.map((o) {
        final (mode, icon, label) = o;
        final selected = current == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(mode),
            child: Container(
              margin: EdgeInsets.only(
                right: mode == ThemeMode.system ? 0 : 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryLight
                    : cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : cs.outline,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: selected ? AppColors.primary : cs.onSurface,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: tt.labelMedium?.copyWith(
                      color: selected ? AppColors.primary : null,
                      fontWeight: selected ? FontWeight.w700 : null,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Section Label ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final TextTheme tt;
  const _SectionLabel({required this.label, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
