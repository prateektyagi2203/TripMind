import 'package:flutter/material.dart';

import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';

/// Family & sharing — empty state. Mirrors `_app.profile.family.tsx`.
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Column(
        children: const [
          ScreenHeader(title: 'Family & sharing', leading: BackLeading()),
          Expanded(
            child: EmptyState(
              icon: Icons.group_rounded,
              title: 'Invite your travel circle',
              subtitle:
                  'Share trips, expenses, and itineraries with family in real-time.',
            ),
          ),
        ],
      ),
    );
  }
}
