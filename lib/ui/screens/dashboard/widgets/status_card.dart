import 'package:flutter/material.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/core/utils/currency_formatter.dart';
import 'package:uang_kos/core/utils/date_formatter.dart';
import 'package:uang_kos/models/payment.dart';

class StatusCard extends StatelessWidget {
  final Payment? payment; // null = belum bayar
  final VoidCallback onTap;

  const StatusCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final paid   = payment != null;
    final tt     = Theme.of(context).textTheme;

    final Color bgColor = paid
        ? AppColors.primaryLight
        : AppColors.dangerLight;
    final Color iconBg = paid
        ? AppColors.primary
        : AppColors.danger;
    final Color textColor = paid
        ? AppColors.primaryDark
        : AppColors.danger;
    final String statusLabel = paid
        ? AppStrings.statusSudahBayar
        : AppStrings.statusBelumBayar;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconBg.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            // ── Icon ──────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                paid
                    ? Icons.check_circle_outline_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // ── Info ──────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bulan Ini',
                    style: tt.bodyMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusLabel,
                    style: tt.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  if (paid) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${CurrencyFormatter.format(payment!.amount)}'
                      ' · ${DateFormatter.dayMonth(payment!.paymentDate)}',
                      style: tt.bodyMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Arrow ─────────────────────────────
            Icon(
              Icons.chevron_right_rounded,
              color: textColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
