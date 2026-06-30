import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/screen.dart';
import '../../itinerary/application/itinerary_repository.dart';
import '../../itinerary/domain/itinerary.dart';
import '../../itinerary/presentation/itinerary_planner_screen.dart';
import '../../itinerary/presentation/plan_prompt.dart';
import '../../trips/domain/trip.dart';

/// Trip Detail — the saved day-by-day plan plus stays & flights, all driven by
/// the real [Trip]. Reached by tapping a trip card on the Trips home.
class TripDetailScreen extends ConsumerWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(itineraryProvider(trip.id));
    final allFlights = trip.journeys
        .where((j) => j.mode == TransportMode.flight)
        .toList();
    // We only plan the departure (home) flight. Prefer journeys flagged as
    // heading 'Home'; fall back to any flight for trips saved before this.
    final homeFlights = allFlights
        .where((j) => j.toCity.toLowerCase() == 'home')
        .toList();
    final flights = homeFlights.isNotEmpty ? homeFlights : allFlights;
    final stays = trip.destinations
        .where((d) => d.hotelName.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(trip: trip),
          planAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.ocean),
              ),
            ),
            error: (_, _) => _PlanError(
              onRetry: () => ref.invalidate(itineraryProvider(trip.id)),
            ),
            data: (plan) => _PlanSection(trip: trip, plan: plan),
          ),
          if (stays.isNotEmpty)
            Section(
              title: 'Stays',
              child: Column(
                children: [
                  for (final d in stays)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StayCard(destination: d),
                    ),
                ],
              ),
            ),
          if (flights.isNotEmpty)
            Section(
              title: 'Flights',
              child: Column(
                children: [
                  for (final j in flights)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FlightCard(journey: j),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---- Plan section --------------------------------------------------------
class _PlanSection extends ConsumerWidget {
  final Trip trip;
  final ItineraryPlan plan;
  const _PlanSection({required this.trip, required this.plan});

  Future<void> _openPlanner(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItineraryPlannerScreen(
          trip: trip,
          aiMode: plan.isEmpty,
          existing: plan.isEmpty ? null : plan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (plan.isEmpty) {
      return Section(
        title: 'Day-by-day plan',
        child: _EmptyPlan(onPlan: () => PlanPrompt.show(context, trip)),
      );
    }
    return Section(
      title: 'Day-by-day plan',
      action: GestureDetector(
        onTap: () => _openPlanner(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.ocean.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 15, color: AppColors.ocean),
              SizedBox(width: 4),
              Text(
                'Edit plan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ocean,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < plan.days.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DayPlanCard(index: i, day: plan.days[i]),
            ),
        ],
      ),
    );
  }
}

class _EmptyPlan extends StatelessWidget {
  final VoidCallback onPlan;
  const _EmptyPlan({required this.onPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.ocean.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.event_note_rounded, color: AppColors.ocean),
          ),
          const SizedBox(height: 14),
          const Text(
            'No plan yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Map out your days until your flight home. I can suggest things '
            'near your hotel, or you can enter your own.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPlan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Plan your days'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPlanCard extends StatelessWidget {
  final int index;
  final ItineraryDay day;
  const _DayPlanCard({required this.index, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${index + 1}'
                        '${day.date.isNotEmpty ? ' · ${_fmtDate(day.date)}' : ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      if (day.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            day.title,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (day.isLight)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sunset.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wb_sunny_rounded,
                          size: 13,
                          color: AppColors.sunset,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Light day',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sunset,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (day.activities.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                'A relaxed day — nothing scheduled.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  for (final a in day.activities) _ActivityTile(activity: a),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: activity.category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              activity.category.icon,
              size: 17,
              color: activity.category.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (activity.time.isNotEmpty) ...[
                      Text(
                        activity.time,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ocean,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
                if (activity.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      activity.description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                if (activity.locationAddress.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            activity.locationAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                        if (activity.rating.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: AppColors.sunset,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            activity.rating,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
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

class _PlanError extends StatelessWidget {
  final VoidCallback onRetry;
  const _PlanError({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Couldn\'t load the plan.',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ---- Hero ----------------------------------------------------------------
class _Hero extends StatelessWidget {
  final Trip trip;
  const _Hero({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: trip.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trip.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              trip.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 15,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trip.route.isNotEmpty ? trip.route : 'Your trip',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (trip.startDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_fmtDate(trip.startDate)} – ${_fmtDate(trip.endDate)}',
                      style: const TextStyle(fontSize: 13, color: Colors.white),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

// ---- Stay & flight cards -------------------------------------------------
class _StayCard extends StatelessWidget {
  final Destination destination;
  const _StayCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[];
    if (destination.checkin.isNotEmpty) {
      rows.add(('Check-in', _fmtDate(destination.checkin)));
    }
    if (destination.checkout.isNotEmpty) {
      rows.add(('Check-out', _fmtDate(destination.checkout)));
    }
    return _InfoCard(
      icon: Icons.hotel_outlined,
      iconColor: AppColors.ocean,
      title: destination.hotelName,
      subtitle: '',
      rows: rows,
    );
  }
}

class _FlightCard extends StatelessWidget {
  final Journey journey;
  const _FlightCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final title = [
      if (journey.flightNumber.isNotEmpty) journey.flightNumber,
      if (journey.route.isNotEmpty) journey.route,
    ].join(' · ');
    final rows = <(String, String)>[];
    if (journey.depart.isNotEmpty) {
      rows.add(('Departs (local)', _fmtFlightWhen(journey.depart)));
    }
    final terminalGate = [
      if (journey.departureTerminal.isNotEmpty) 'T${journey.departureTerminal}',
      if (journey.departureGate.isNotEmpty) 'Gate ${journey.departureGate}',
    ].join(' · ');
    if (terminalGate.isNotEmpty) rows.add(('Terminal / Gate', terminalGate));
    return _InfoCard(
      icon: Icons.flight_takeoff_rounded,
      iconColor: AppColors.sunset,
      title: title.isNotEmpty
          ? title
          : (journey.airline.isNotEmpty ? journey.airline : 'Flight'),
      subtitle: journey.statusNote.isNotEmpty
          ? journey.statusNote
          : (journey.status.isNotEmpty ? journey.status : journey.airline),
      rows: rows,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<(String, String)> rows;
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
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
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.$1,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      r.$2,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _fmtDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  const mo = [
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
  return '${d.day} ${mo[d.month - 1]}';
}

String _fmtFlightWhen(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso.replaceFirst('T', ' ');
  final dateStr = _fmtDate(iso);
  // A time was captured when the value carries a time component.
  if (iso.contains('T')) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$dateStr · $hh:$mm';
  }
  return dateStr;
}
