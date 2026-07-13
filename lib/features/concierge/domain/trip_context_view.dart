/// Lightweight view of the backend TripContext, used to render the context
/// strip pills on the Concierge header. Only the fields the UI needs are parsed.
class TripContextView {
  final String area;
  final int tempC;
  final String condition;
  final int budgetRemainingThb;
  final int familySize;
  final String hotelName;

  const TripContextView({
    required this.area,
    required this.tempC,
    required this.condition,
    required this.budgetRemainingThb,
    required this.familySize,
    required this.hotelName,
  });

  factory TripContextView.fromJson(Map<String, dynamic> json) {
    final env = Map<String, dynamic>.from(json['environment'] as Map);
    final weather = Map<String, dynamic>.from(env['weather'] as Map);
    final gps = Map<String, dynamic>.from(env['gps'] as Map);
    final budget = Map<String, dynamic>.from(json['budget'] as Map);
    final user = Map<String, dynamic>.from(json['user'] as Map);
    final hotel = Map<String, dynamic>.from(json['hotel'] as Map);
    return TripContextView(
      area: gps['area'] as String,
      tempC: (weather['temp_c'] as num).round(),
      condition: (weather['condition'] as String).replaceAll('_', ' '),
      budgetRemainingThb: (budget['remaining_thb'] as num).round(),
      familySize: (user['family_size'] as num).round(),
      hotelName: hotel['name'] as String,
    );
  }
}
