import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/core/utils/currency_formatter.dart';
import 'package:uang_kos/core/utils/date_formatter.dart';
import 'package:uang_kos/models/payment.dart';
import 'package:uang_kos/providers/payment_provider.dart';
import 'package:uang_kos/ui/screens/history/widgets/payment_form_sheet.dart';

class PaymentListTile extends ConsumerWidget {
  final Payment payment;
  const PaymentListTile({super.key, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),

          // ── Info ──────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(payment.amount),
                  style: tt.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bayar: ${DateFormatter.dayMonthYear(payment.paymentDate)}',
                  style: tt.bodyMedium?.copyWith(fontSize: 12),
                ),
                if (payment.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment.note!,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ── Actions ───────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => PaymentFormSheet(existing: payment),
                ),
              ),
              const SizedBox(width: 4),
              _ActionBtn(
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                onTap: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.labelKonfirmasiHapus),
        content: const Text(AppStrings.labelKonfirmasiHapusDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.labelBatal),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.labelHapus),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(paymentProvider.notifier).delete(payment);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.msgPembayaranDihapus),
          ),
        );
      }
    }
  }
}

// ── Action Button ────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
