import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/trip.dart';

class HotelMatch {
  final String name;
  final String address;
  final List<String> suggestions;
  const HotelMatch({
    required this.name,
    required this.address,
    this.suggestions = const [],
  });

  factory HotelMatch.fromJson(Map<String, dynamic> j) => HotelMatch(
    name: j['name'] as String? ?? '',
    address: j['address'] as String? ?? '',
    suggestions: (j['suggestions'] as List<dynamic>? ?? [])
        .map((s) => s.toString())
        .toList(),
  );
}

class HotelOption {
  final String name;
  final String address;
  const HotelOption({required this.name, this.address = ''});

  factory HotelOption.fromJson(Map<String, dynamic> j) => HotelOption(
    name: j['name'] as String? ?? '',
    address: j['address'] as String? ?? '',
  );
}

class TripsRepository {
  final Dio _dio;
  TripsRepository(this._dio);

  Future<List<Trip>> list() async {
    final res = await _dio.get<List<dynamic>>('/api/trips');
    return (res.data ?? [])
        .map((t) => Trip.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<Trip> create({
    required String name,
    required String startDate,
    required String endDate,
    required String currency,
    required String coverGradient,
    required List<Destination> destinations,
    required List<Journey> journeys,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/trips',
      data: {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'currency': currency,
        'cover_gradient': coverGradient,
        'destinations': destinations.map((d) => d.toJson()).toList(),
        'journeys': journeys.map((j) => j.toJson()).toList(),
      },
    );
    return Trip.fromJson(res.data!);
  }

  Future<Trip> update({
    required String tripId,
    required String name,
    required String startDate,
    required String endDate,
    required String currency,
    required String coverGradient,
    required List<Destination> destinations,
    required List<Journey> journeys,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/trips/$tripId',
      data: {
        'name': name,
        'start_date': startDate,
        'end_date': endDate,
        'currency': currency,
        'cover_gradient': coverGradient,
        'destinations': destinations.map((d) => d.toJson()).toList(),
        'journeys': journeys.map((j) => j.toJson()).toList(),
      },
    );
    return Trip.fromJson(res.data!);
  }

  Future<Trip> join(String code) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/trips/join',
      data: {'code': code},
    );
    return Trip.fromJson(res.data!);
  }

  Future<HotelMatch> resolveHotel(String query, String city) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/hotels/resolve',
      data: {'query': query, 'city': city},
    );
    return HotelMatch.fromJson(res.data!);
  }

  /// Exhaustive hotel search — returns every matching property (e.g. all
  /// Novotel hotels in/near the city).
  Future<List<HotelOption>> searchHotels(String query, String city) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/hotels/search',
      data: {'query': query, 'city': city},
    );
    final results = res.data?['results'] as List<dynamic>? ?? [];
    return results
        .map((r) => HotelOption.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Refresh live flight status for a trip's flights and return the updated trip.
  Future<List<dynamic>> refreshFlights(String tripId) async {
    final res = await _dio.post<List<dynamic>>(
      '/api/trips/$tripId/flights/refresh',
    );
    return res.data ?? [];
  }
}

final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return TripsRepository(ref.watch(dioProvider));
});

/// All trips the signed-in user owns or has joined.
final tripsListProvider = FutureProvider<List<Trip>>((ref) async {
  return ref.watch(tripsRepositoryProvider).list();
});
