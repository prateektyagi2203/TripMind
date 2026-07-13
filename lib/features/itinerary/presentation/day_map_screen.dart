import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';
import '../application/itinerary_repository.dart';
import '../domain/day_route.dart';

/// Shows every planned stop for one day on a map, connected in visiting
/// order, with real (or best-effort estimated) distance between each stop.
class DayMapScreen extends ConsumerWidget {
  final String tripId;
  final int dayIndex;
  final String dayTitle;

  const DayMapScreen({
    super.key,
    required this.tripId,
    required this.dayIndex,
    required this.dayTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dayRouteProvider((tripId, dayIndex)));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: dayTitle.isEmpty ? 'Day map' : dayTitle, leading: const BackLeading()),
            Expanded(
              child: async.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.ocean),
                ),
                error: (_, _) => const Center(
                  child: Text(
                    'Couldn\'t load the map for this day.',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                ),
                data: (route) => _DayMapBody(route: route),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayMapBody extends StatelessWidget {
  final DayRoute route;
  const _DayMapBody({required this.route});

  @override
  Widget build(BuildContext context) {
    if (route.stops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            route.skipped > 0
                ? 'None of this day\'s ${route.skipped} activities have a '
                    'location we could place on the map yet.'
                : 'No activities planned for this day.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedForeground),
          ),
        ),
      );
    }

    final points = route.stops.map((s) => LatLng(s.lat, s.lng)).toList();
    final bounds = LatLngBounds.fromPoints(points);

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(48),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tripmind.tripmind',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(points: points, strokeWidth: 4, color: AppColors.ocean),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < points.length; i++)
                    Marker(
                      point: points[i],
                      width: 32,
                      height: 32,
                      child: _StopPin(index: i + 1),
                    ),
                ],
              ),
            ],
          ),
        ),
        _RouteSummary(route: route),
      ],
    );
  }
}

class _StopPin extends StatelessWidget {
  final int index;
  const _StopPin({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ocean,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RouteSummary extends StatelessWidget {
  final DayRoute route;
  const _RouteSummary({required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${route.totalDistanceKm.toStringAsFixed(1)} km total'
                  ' · ~${route.totalDurationMin.round()} min travel',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            if (route.source == 'approximate')
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Estimated — actual road distance may vary.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.mutedForeground),
                ),
              ),
            if (route.skipped > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${route.skipped} ${route.skipped == 1 ? 'activity' : 'activities'} '
                  'not shown — no location found.',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.mutedForeground),
                ),
              ),
            const SizedBox(height: 10),
            for (var i = 0; i < route.stops.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StopPin(index: i + 1),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      route.stops[i].title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              if (i < route.legs.length)
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 2,
                        height: 16,
                        child: DecoratedBox(decoration: BoxDecoration(color: AppColors.border)),
                      ),
                      const SizedBox(width: 13),
                      Text(
                        '${route.legs[i].distanceKm.toStringAsFixed(1)} km '
                        '· ~${route.legs[i].durationMin.round()} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
