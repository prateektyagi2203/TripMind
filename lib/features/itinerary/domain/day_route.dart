/// One stop on a day's route, with real coordinates.
class RouteStop {
  final String title;
  final double lat;
  final double lng;

  const RouteStop({required this.title, required this.lat, required this.lng});

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      title: json['title'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Distance/duration between two consecutive stops.
class RouteLeg {
  final double distanceKm;
  final double durationMin;

  const RouteLeg({required this.distanceKm, required this.durationMin});

  factory RouteLeg.fromJson(Map<String, dynamic> json) {
    return RouteLeg(
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      durationMin: (json['duration_min'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A day's plan as an ordered route: stops with coordinates, plus real (or
/// estimated) distance/duration between each consecutive pair.
class DayRoute {
  final String source; // "routed" | "approximate"
  final List<RouteStop> stops;
  final List<RouteLeg> legs;
  final double totalDistanceKm;
  final double totalDurationMin;
  final int skipped;

  const DayRoute({
    required this.source,
    required this.stops,
    required this.legs,
    required this.totalDistanceKm,
    required this.totalDurationMin,
    required this.skipped,
  });

  factory DayRoute.fromJson(Map<String, dynamic> json) {
    return DayRoute(
      source: json['source'] as String? ?? 'approximate',
      stops: (json['stops'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(RouteStop.fromJson)
          .toList(),
      legs: (json['legs'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(RouteLeg.fromJson)
          .toList(),
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0,
      totalDurationMin: (json['total_duration_min'] as num?)?.toDouble() ?? 0,
      skipped: (json['skipped'] as num?)?.toInt() ?? 0,
    );
  }
}
