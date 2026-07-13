import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/screen.dart';
import '../../trip_create/presentation/create_trip_screen.dart';
import '../../trip_detail/presentation/trip_detail_screen.dart';
import '../domain/trip.dart';

/// Trip card backed by a real (persisted) [Trip] from the backend.
class TripCard extends StatelessWidget {
  final Trip trip;
  const TripCard({super.key, required this.trip});

  String _prettyDates() {
    String pretty(String iso) {
      final p = iso.split('-');
      if (p.length != 3) return iso;
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final m = int.tryParse(p[1]) ?? 1;
      return '${months[(m - 1).clamp(0, 11)]} ${int.tryParse(p[2]) ?? p[2]}';
    }

    if (trip.startDate.isEmpty || trip.endDate.isEmpty) return '';
    final year = trip.endDate.split('-').first;
    return '${pretty(trip.startDate)} – ${pretty(trip.endDate)}, $year';
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = trip.members.length;
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: kSoftShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: trip.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 16,
                    child: _Badge(text: trip.status),
                  ),
                  if (trip.inviteCode.isNotEmpty)
                    Positioned(
                      right: 16,
                      top: 16,
                      child: _Badge(text: 'Invite code ${trip.inviteCode}'),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trip.route.isNotEmpty)
                          Text(
                            trip.route.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.4,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          trip.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetaRow(
                          icon: Icons.calendar_today_outlined,
                          text: _prettyDates(),
                        ),
                        const SizedBox(height: 4),
                        _MetaRow(
                          icon: Icons.group_outlined,
                          text:
                              '$memberCount traveler${memberCount == 1 ? '' : 's'}',
                        ),
                      ],
                    ),
                  ),
                  if (trip.role == 'owner') ...[
                    IconButton(
                      tooltip: 'Edit trip',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.ocean,
                      ),
                      onPressed: () => CreateTripScreen.edit(context, trip),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sunset.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trip.role == 'owner' ? 'Owner' : 'Joined',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sunset,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mutedForeground),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
