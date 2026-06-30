import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';

/// Subscription / billing. Mirrors `_app.profile.billing.tsx`.
class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  static const _features = [
    'Unlimited trips & destination packs',
    'AI concierge with full context',
    'Family sharing up to 6',
    'Offline maps & translator',
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Column(
        children: [
          const ScreenHeader(title: 'Subscription', leading: BackLeading()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                GradientHeroCard(
                  colors: AppColors.gradientSunset,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT PLAN',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'TripMind Pro',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  f,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
