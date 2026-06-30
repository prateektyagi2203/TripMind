import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';
import 'atms_screen.dart';
import 'cabhub_screen.dart';
import 'camera_screen.dart';
import 'nearby_screen.dart';
import 'receipts_screen.dart';
import 'safety_screen.dart';
import 'translator_screen.dart';
import 'weather_screen.dart';

/// Tools hub — the travel toolkit. Mirrors Lovable `_app.tools.tsx`.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = <_Tool>[
      _Tool(
        Icons.directions_car_rounded,
        const Color(0xFFD97706),
        'CabHub',
        'Compare Grab, Bolt, inDrive',
        () => const CabHubScreen(),
      ),
      _Tool(
        Icons.explore_rounded,
        const Color(0xFF0D9488),
        'Nearby Places',
        'Beaches, malls, parks, zoos',
        () => const NearbyScreen(),
      ),
      _Tool(
        Icons.account_balance_rounded,
        const Color(0xFF4F46E5),
        'Nearby ATMs',
        'Cash points with travel time',
        () => const AtmsScreen(),
      ),
      _Tool(
        Icons.translate_rounded,
        const Color(0xFF059669),
        'Translator',
        'Camera, voice, text',
        () => const TranslatorScreen(),
      ),
      _Tool(
        Icons.photo_camera_rounded,
        const Color(0xFFE11D48),
        'Camera AI',
        'Recognize, scan receipts',
        () => const CameraScreen(),
      ),
      _Tool(
        Icons.shield_rounded,
        const Color(0xFF2563EB),
        'Safety',
        'Hospitals, embassy, SOS',
        () => const SafetyScreen(),
      ),
      _Tool(
        Icons.cloud_rounded,
        const Color(0xFF0EA5E9),
        'Weather',
        'Local forecast',
        () => const WeatherScreen(),
      ),
      _Tool(
        Icons.receipt_long_rounded,
        const Color(0xFF9333EA),
        'Receipts',
        'Scan and log',
        () => const ReceiptsScreen(),
      ),
    ];

    return Screen(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: _Header(),
          ),
          Section(
            title: 'Your travel toolkit',
            child: Column(
              children: tools
                  .map(
                    (t) => NavRow(
                      icon: t.icon,
                      iconColor: t.color,
                      title: t.title,
                      subtitle: t.subtitle,
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => t.build())),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TOOLKIT',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Everything for the road',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ],
    );
  }
}

class _Tool {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget Function() build;
  const _Tool(this.icon, this.color, this.title, this.subtitle, this.build);
}
