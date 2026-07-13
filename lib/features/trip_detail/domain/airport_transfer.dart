/// A single ride-hailing / taxi option for the Day 1 airport -> hotel leg.
class TransferProvider {
  final String name;
  final int priceThb;
  final int etaMin;
  final bool bestValue;

  const TransferProvider({
    required this.name,
    required this.priceThb,
    required this.etaMin,
    required this.bestValue,
  });

  factory TransferProvider.fromJson(Map<String, dynamic> json) {
    return TransferProvider(
      name: json['name'] as String? ?? '',
      priceThb: (json['price_thb'] as num?)?.toInt() ?? 0,
      etaMin: (json['eta_min'] as num?)?.toInt() ?? 0,
      bestValue: json['best_value'] as bool? ?? false,
    );
  }
}

/// Day 1 airport -> hotel transfer estimate: distance plus a shortlist of
/// Thailand ride-hailing / taxi options with approximate cost and ETA.
///
/// Prices are always a fare-formula estimate, never a live quote — no
/// ride-hailing app exposes a public price API. [source] only describes how
/// the *distance/duration* were derived:
/// - "routed": real driving distance/duration from OpenRouteService.
/// - "geocoded": hotel location is real but distance is a straight-line estimate.
/// - "approximate": neither the hotel location nor the distance is precise.
class AirportTransfer {
  final String airportCode;
  final String airportName;
  final String hotelName;
  final double distanceKm;
  final String source;
  final double airportLat;
  final double airportLng;
  final double hotelLat;
  final double hotelLng;
  final List<TransferProvider> providers;

  const AirportTransfer({
    required this.airportCode,
    required this.airportName,
    required this.hotelName,
    required this.distanceKm,
    required this.source,
    required this.airportLat,
    required this.airportLng,
    required this.hotelLat,
    required this.hotelLng,
    required this.providers,
  });

  factory AirportTransfer.fromJson(Map<String, dynamic> json) {
    final providers = (json['providers'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(TransferProvider.fromJson)
        .toList();
    return AirportTransfer(
      airportCode: json['airport_code'] as String? ?? '',
      airportName: json['airport_name'] as String? ?? '',
      hotelName: json['hotel_name'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      source: json['source'] as String? ?? 'approximate',
      airportLat: (json['airport_lat'] as num?)?.toDouble() ?? 0,
      airportLng: (json['airport_lng'] as num?)?.toDouble() ?? 0,
      hotelLat: (json['hotel_lat'] as num?)?.toDouble() ?? 0,
      hotelLng: (json['hotel_lng'] as num?)?.toDouble() ?? 0,
      providers: providers,
    );
  }
}
