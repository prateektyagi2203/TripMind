import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';

/// Notifications. Mirrors `_app.profile.notifications.tsx`.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = <(IconData, String, String, String)>[
    (
      Icons.flight_rounded,
      'Flight TG 316 on time',
      '2h ago',
      'Boarding gate updates will appear here.',
    ),
    (
      Icons.cloudy_snowing,
      'Showers expected in Bangkok',
      '5h ago',
      'Pack a light raincoat for Day 2.',
    ),
    (
      Icons.account_balance_wallet_rounded,
      'Priya added an expense',
      'Yesterday',
      'Airport taxi · ฿1,100',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Column(
        children: [
          const ScreenHeader(title: 'Notifications', leading: BackLeading()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                for (final (icon, title, time, body) in _items)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.ocean.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, size: 18, color: AppColors.ocean),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.foreground,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                body,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
