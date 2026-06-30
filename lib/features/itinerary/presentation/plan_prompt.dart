import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../trips/domain/trip.dart';
import 'itinerary_planner_screen.dart';

/// Asks the traveller, right after creating a trip, whether they'd like to
/// build a day-by-day plan — and how (let AI help, or enter their own).
class PlanPrompt {
  static Future<void> show(BuildContext context, Trip trip) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PlanPromptSheet(trip: trip),
    );
  }
}

class _PlanPromptSheet extends StatelessWidget {
  final Trip trip;
  const _PlanPromptSheet({required this.trip});

  void _openPlanner(BuildContext context, {required bool aiMode}) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItineraryPlannerScreen(trip: trip, aiMode: aiMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Plan your days?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Map out ${trip.name} day by day — until your flight home. '
            'I can suggest things near your hotel, or you can enter your own.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 22),
          _Option(
            icon: Icons.auto_awesome_rounded,
            color: AppColors.ocean,
            title: 'Help me plan',
            subtitle: 'AI suggests a day-by-day plan near your hotel',
            onTap: () => _openPlanner(context, aiMode: true),
          ),
          const SizedBox(height: 12),
          _Option(
            icon: Icons.edit_calendar_rounded,
            color: AppColors.sunset,
            title: 'I\'ll enter my own',
            subtitle: 'Add your decided itinerary day by day',
            onTap: () => _openPlanner(context, aiMode: false),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Maybe later',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Option({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
