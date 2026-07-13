import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/screen.dart';
import '../domain/trip.dart';

/// Compact live-status card for a single tracked flight, shown on the home
/// screen when a flight is within ~24h of departure.
class FlightStatusCard extends StatelessWidget {
  final String tripName;
  final Journey journey;
  const FlightStatusCard({
    super.key,
    required this.tripName,
    required this.journey,
  });

  ({Color color, String label, IconData icon}) get _status {
    switch (journey.status) {
      case 'delayed':
        return (
          color: AppColors.sunset,
          label: 'Delayed',
          icon: Icons.schedule_rounded,
        );
      case 'cancelled':
        return (
          color: AppColors.destructive,
          label: 'Cancelled',
          icon: Icons.cancel_rounded,
        );
      case 'diverted':
        return (
          color: AppColors.destructive,
          label: 'Diverted',
          icon: Icons.alt_route_rounded,
        );
      case 'active':
        return (
          color: AppColors.ocean,
          label: 'In the air',
          icon: Icons.flight_rounded,
        );
      case 'landed':
        return (
          color: AppColors.primary,
          label: 'Landed',
          icon: Icons.flight_land_rounded,
        );
      case 'scheduled':
        return (
          color: AppColors.primary,
          label: 'On time',
          icon: Icons.check_circle_rounded,
        );
      default:
        return (
          color: AppColors.mutedForeground,
          label: 'Awaiting update',
          icon: Icons.flight_takeoff_rounded,
        );
    }
  }

  String _time(String iso) {
    // Accept "2026-07-12T14:30..." or "2026-07-12 14:30" → "14:30".
    final t = iso.contains('T') ? iso.split('T').last : iso.split(' ').last;
    if (t.length >= 5) return t.substring(0, 5);
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    final depTime = _time(
      journey.estimatedDeparture.isNotEmpty
          ? journey.estimatedDeparture
          : journey.scheduledDeparture,
    );
    final hasGate =
        journey.departureTerminal.isNotEmpty ||
        journey.departureGate.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: s.color.withValues(alpha: 0.4)),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(s.icon, size: 18, color: s.color),
              const SizedBox(width: 8),
              Text(
                journey.flightNumber.isEmpty ? 'Flight' : journey.flightNumber,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (journey.airline.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    journey.airline,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: s.color,
                  ),
                ),
              ),
            ],
          ),
          if (journey.statusNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              journey.statusNote,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: s.color,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (journey.route.isNotEmpty)
                _Chip(icon: Icons.route_rounded, text: journey.route),
              if (depTime.isNotEmpty)
                _Chip(icon: Icons.access_time_rounded, text: 'Dep $depTime'),
              if (hasGate)
                _Chip(
                  icon: Icons.meeting_room_rounded,
                  text: [
                    if (journey.departureTerminal.isNotEmpty)
                      'T${journey.departureTerminal}',
                    if (journey.departureGate.isNotEmpty)
                      'Gate ${journey.departureGate}',
                  ].join(' · '),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            journey.statusCheckedAt.isEmpty
                ? 'Live status begins ~24h before departure'
                : 'For "$tripName"',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.mutedForeground),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.foreground),
          ),
        ],
      ),
    );
  }
}
