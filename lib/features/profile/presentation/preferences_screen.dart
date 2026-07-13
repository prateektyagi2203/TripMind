import 'package:flutter/material.dart';

import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';

/// Travel preferences — empty state. Mirrors `_app.profile.preferences.tsx`.
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Column(
        children: const [
          ScreenHeader(title: 'Travel preferences', leading: BackLeading()),
          Expanded(
            child: EmptyState(
              icon: Icons.tune_rounded,
              title: 'Tune your Travel DNA',
              subtitle:
                  'Pace, cuisine, dietary needs, accessibility — your concierge adapts to it all.',
            ),
          ),
        ],
      ),
    );
  }
}
