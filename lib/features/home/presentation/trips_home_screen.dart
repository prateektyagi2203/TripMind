import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';
import '../../itinerary/presentation/plan_prompt.dart';
import '../../trip_create/presentation/create_trip_screen.dart';
import '../../trips/application/trips_repository.dart';
import '../../trips/domain/trip.dart';
import '../../trips/presentation/flight_status_card.dart';
import '../../trips/presentation/join_trip_screen.dart';
import '../../trips/presentation/trip_card.dart';

/// Trips home — "Where to next?" Lists the signed-in user's trips (owned +
/// joined) from the backend, with create / join entry points.
class TripsHomeScreen extends ConsumerWidget {
  const TripsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsListProvider);

    Future<void> openCreate() async {
      final trip = await CreateTripScreen.show(context);
      if (trip != null && context.mounted) {
        await PlanPrompt.show(context, trip);
      }
    }

    Future<void> openJoin() async {
      await JoinTripScreen.show(context);
    }

    Future<void> refresh() async {
      final repo = ref.read(tripsRepositoryProvider);
      final current = ref.read(tripsListProvider).valueOrNull ?? const <Trip>[];
      for (final t in current.where((t) => t.status != 'Completed')) {
        final hasFlight = t.journeys.any(
          (j) => j.mode == TransportMode.flight && j.flightNumber.isNotEmpty,
        );
        if (hasFlight) {
          try {
            await repo.refreshFlights(t.id);
          } catch (_) {
            // Live status is best-effort (needs RAPIDAPI_KEY); ignore failures.
          }
        }
      }
      ref.invalidate(tripsListProvider);
      await ref.read(tripsListProvider.future);
    }

    return Screen(
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Header(onCreate: openCreate),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_rounded,
                      label: 'New trip',
                      filled: true,
                      onTap: openCreate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.group_add_rounded,
                      label: 'Join with code',
                      onTap: openJoin,
                    ),
                  ),
                ],
              ),
            ),
            tripsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load trips',
                  subtitle: 'Is the backend running on port 8000?',
                ),
              ),
              data: (trips) => _TripsBody(trips: trips, onCreate: openCreate),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsBody extends StatelessWidget {
  final List<Trip> trips;
  final VoidCallback onCreate;
  const _TripsBody({required this.trips, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
        child: EmptyState(
          icon: Icons.luggage_rounded,
          title: 'No trips yet',
          subtitle: 'Create your first trip or join one with an invite code.',
          action: FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create a trip'),
          ),
        ),
      );
    }

    final upcoming = trips.where((t) => t.status != 'Completed').toList();
    final past = trips.where((t) => t.status == 'Completed').toList();
    final trackedFlights = _trackedFlights(upcoming);

    return Column(
      children: [
        if (trackedFlights.isNotEmpty)
          Section(
            title: 'Flight status',
            child: Column(
              children: trackedFlights
                  .map(
                    (f) => FlightStatusCard(
                      tripName: f.tripName,
                      journey: f.journey,
                    ),
                  )
                  .toList(),
            ),
          ),
        if (upcoming.isNotEmpty)
          Section(
            title: 'Your trips',
            child: Column(
              children: upcoming.map((t) => TripCard(trip: t)).toList(),
            ),
          ),
        if (past.isNotEmpty)
          Section(
            title: 'Travel memories',
            child: Column(
              children: past.map((t) => TripCard(trip: t)).toList(),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCreate;
  const _Header({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.8,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Where to next?',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          _CircleButton(icon: Icons.notifications_none_rounded, onTap: () {}),
          const SizedBox(width: 10),
          _CircleButton(icon: Icons.add_rounded, filled: true, onTap: onCreate),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: AppColors.gradientSunset)
              : null,
          color: filled ? null : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: filled ? null : Border.all(color: AppColors.border),
          boxShadow: kSoftShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: filled ? Colors.white : AppColors.foreground,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: AppColors.gradientSunset)
              : null,
          color: filled ? null : AppColors.card,
          shape: BoxShape.circle,
          boxShadow: kSoftShadow,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? Colors.white : AppColors.foreground,
        ),
      ),
    );
  }
}

/// A flight worth surfacing on the home screen, with its owning trip's name.
class _TrackedFlight {
  final String tripName;
  final Journey journey;
  const _TrackedFlight({required this.tripName, required this.journey});
}

/// Collects flights to show under "Flight status": flight-mode journeys with a
/// flight number that either already have a live status, or depart/arrive
/// within ~24h (the window where the backend begins polling).
List<_TrackedFlight> _trackedFlights(List<Trip> upcoming) {
  final out = <_TrackedFlight>[];
  for (final t in upcoming) {
    for (final j in t.journeys) {
      if (j.mode != TransportMode.flight || j.flightNumber.isEmpty) continue;
      if (j.status.isNotEmpty || _withinDay(j.depart) || _withinDay(j.arrive)) {
        out.add(_TrackedFlight(tripName: t.name, journey: j));
      }
    }
  }
  return out;
}

/// True when [date] (YYYY-MM-DD or ISO) is today or tomorrow.
bool _withinDay(String date) {
  if (date.isEmpty) return false;
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(parsed.year, parsed.month, parsed.day);
  final diff = day.difference(today).inDays;
  return diff >= 0 && diff <= 1;
}
