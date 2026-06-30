import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/itinerary.dart';

class ItineraryRepository {
  final Dio _dio;
  ItineraryRepository(this._dio);

  /// Build a draft AI plan (not saved) seeded with real nearby places.
  Future<ItineraryPlan> generate(String tripId, PlanPreferences prefs) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/trips/$tripId/itinerary/generate',
      data: {'preferences': prefs.toJson()},
    );
    return ItineraryPlan.fromJson(res.data!);
  }

  /// Fetch the saved plan for a trip.
  Future<ItineraryPlan> get(String tripId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/trips/$tripId/itinerary',
    );
    return ItineraryPlan.fromJson(res.data!);
  }

  /// Persist the full plan (replaces any existing days).
  Future<ItineraryPlan> save(String tripId, List<ItineraryDay> days) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/trips/$tripId/itinerary',
      data: {'days': days.map((d) => d.toJson()).toList()},
    );
    return ItineraryPlan.fromJson(res.data!);
  }

  /// Browse real nearby places for the trip. When [query] is given it runs a
  /// free-text search (e.g. "Indian food restaurant") instead of a category browse.
  Future<List<NearbyPlace>> nearby(
    String tripId, {
    String category = 'all',
    String query = '',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/trips/$tripId/places/nearby',
      queryParameters: {
        'category': category,
        if (query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    final results = res.data?['results'] as List<dynamic>? ?? [];
    return results
        .map((r) => NearbyPlace.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Look up a flight's local departure time (HH:MM) by number + date.
  /// Returns null when the flight can't be found (caller keeps manual entry).
  Future<String?> lookupFlightTime(String flightNumber, String date) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/flights/lookup',
      data: {'flight_number': flightNumber, 'date': date},
    );
    final data = res.data;
    if (data == null || data['found'] != true) return null;
    final t = (data['departure_time'] as String?)?.trim() ?? '';
    return t.isEmpty ? null : t;
  }
}

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository(ref.watch(dioProvider));
});

/// Saved itinerary for a given trip id.
final itineraryProvider = FutureProvider.family<ItineraryPlan, String>((
  ref,
  tripId,
) async {
  return ref.watch(itineraryRepositoryProvider).get(tripId);
});
