import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/screen.dart';

/// Renders a `cab_comparison` rich card: provider list with price + ETA and a
/// "Best value" highlight. Mirrors the CabHub comparison pattern.
class CabComparisonCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const CabComparisonCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final destination = data['destination'] as String? ?? 'your destination';
    final providers = (data['providers'] as List? ?? const [])
        .cast<Map<String, dynamic>>();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_taxi_rounded,
                size: 16,
                color: AppColors.ocean,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Rides to $destination',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...providers.map((p) => _ProviderRow(provider: p)),
        ],
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final Map<String, dynamic> provider;
  const _ProviderRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final name = provider['name'] as String? ?? '';
    final price = provider['price_thb'];
    final eta = provider['eta_min'];
    final bestValue = provider['best_value'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                if (bestValue) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sunset.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Best value',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sunset,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '฿$price',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$eta min',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
