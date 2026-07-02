import 'package:flutter/material.dart';
import 'package:uang_kos/core/constants/app_colors.dart';

class ReminderToggleCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const ReminderToggleCard({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.4)
              : cs.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primaryLight
                  : cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: value ? AppColors.primary : cs.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodyLarge?.copyWith(fontSize: 14)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: tt.bodyMedium?.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
