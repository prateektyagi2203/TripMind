import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';

/// Settings — grouped placeholder rows. Mirrors `_app.profile.settings.tsx`.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _groups = <(String, List<String>)>[
    ('APP', ['Appearance', 'Language & region', 'Units & currency']),
    ('PRIVACY', ['Data & sync', 'Permissions', 'Export data']),
    ('SUPPORT', ['Help center', 'Contact us', 'About TripMind']),
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Column(
        children: [
          const ScreenHeader(title: 'Settings', leading: BackLeading()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                for (final (label, items) in _groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  PlainCard(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          _Row(label: items[i]),
                          if (i != items.length - 1)
                            const Divider(height: 1, color: AppColors.border),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  const _Row({required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: AppColors.foreground),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.mutedForeground,
      ),
      onTap: () {},
    );
  }
}
