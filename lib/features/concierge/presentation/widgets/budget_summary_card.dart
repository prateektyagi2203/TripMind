import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/screen.dart';

/// Renders a `budget_summary` rich card: a progress ring + spent/remaining stats.
class BudgetSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const BudgetSummaryCard({super.key, required this.data});

  int _int(String key) => (data[key] as num?)?.round() ?? 0;

  @override
  Widget build(BuildContext context) {
    final total = _int('total_thb');
    final spent = _int('spent_thb');
    final remaining = _int('remaining_thb');
    final pct = total == 0 ? 0.0 : (spent / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 7,
                    backgroundColor: AppColors.muted,
                    valueColor: const AlwaysStoppedAnimation(AppColors.sunset),
                  ),
                ),
                Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(label: 'Total', value: total),
                _StatRow(label: 'Spent', value: spent),
                _StatRow(label: 'Remaining', value: remaining, highlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final bool highlight;
  const _StatRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            '฿${value.toString()}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.ocean : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
