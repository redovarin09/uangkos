import 'package:flutter/material.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/core/utils/currency_formatter.dart';

class YearlySummaryCard extends StatelessWidget {
  final double totalAmount;
  final int paidMonths;
  final int year;

  const YearlySummaryCard({
    super.key,
    required this.totalAmount,
    required this.paidMonths,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final progress = paidMonths / 12;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.labelTotalTahunIni,
                    style: tt.titleSmall,
                  ),
                ],
              ),
              Text(
                '$year',
                style: tt.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Nominal ─────────────────────────────
          Text(
            CurrencyFormatter.format(totalAmount),
            style: tt.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),

          const SizedBox(height: 12),

          // ── Progress bar ────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          const SizedBox(height: 8),

          // ── Count label ─────────────────────────
          Text(
            '$paidMonths ${AppStrings.labelBulanDari12}',
            style: tt.bodyMedium?.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
