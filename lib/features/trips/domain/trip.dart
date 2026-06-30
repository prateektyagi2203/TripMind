import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum TransportMode { cab, selfDrive, flight, ferry, bus, train }

extension TransportModeX on TransportMode {
  String get apiValue => switch (this) {
    TransportMode.cab => 'cab',
    TransportMode.selfDrive => 'self_drive',
    TransportMode.flight => 'flight',
    TransportMode.ferry => 'ferry',
    TransportMode.bus => 'bus',
    TransportMode.train => 'train',
  };

  String get label => switch (this) {
    TransportMode.cab => 'Cab',
    TransportMode.selfDrive => 'Self drive',
    TransportMode.flight => 'Flight',
    TransportMode.ferry => 'Ferry',
    TransportMode.bus => 'Bus',
    TransportMode.train => 'Train',
  };

  IconData get icon => switch (this) {
    TransportMode.cab => Icons.local_taxi_rounded,
    TransportMode.selfDrive => Icons.directions_car_rounded,
    TransportMode.flight => Icons.flight_rounded,
    TransportMode.ferry => Icons.directions_boat_rounded,
    TransportMode.bus => Icons.directions_bus_rounded,
    TransportMode.train => Icons.train_rounded,
  };

  static TransportMode fromApi(String v) => switch (v) {
    'cab' => TransportMode.cab,
    'self_drive' => TransportMode.selfDrive,
    'flight' => TransportMode.flight,
    'ferry' => TransportMode.ferry,
    'bus' => TransportMode.bus,
    'train' => TransportMode.train,
    _ => TransportMode.flight,
  };
}

class Destination {
  final String city;
  final String hotelName;
  final String hotelAddress;
  final String checkin;
  final String checkout;

  const Destination({
    required this.city,
    this.hotelName = '',
    this.hotelAddress = '',
    this.checkin = '',
    this.checkout = '',
  });

  Map<String, dynamic> toJson() => {
    'city': city,
    'hotel_name': hotelName,
    'hotel_address': hotelAddress,
    'checkin': checkin,
    'checkout': checkout,
  };

  factory Destination.fromJson(Map<String, dynamic> j) => Destination(
    city: j['city'] as String? ?? '',
    hotelName: j['hotel_name'] as String? ?? '',
    hotelAddress: j['hotel_address'] as String? ?? '',
    checkin: j['checkin'] as String? ?? '',
    checkout: j['checkout'] as String? ?? '',
  );
}

class Journey {
  final TransportMode mode;
  final String fromCity;
  final String toCity;
  final String pnr;
  final String flightNumber;
  final String airline;
  final String route;
  final String depart;
  final String arrive;
  // Live status snapshot (empty until checked within 24h of travel).
  final String status;
  final String statusNote;
  final String departureTerminal;
  final String departureGate;
  final String arrivalTerminal;
  final String arrivalGate;
  final String scheduledDeparture;
  final String estimatedDeparture;
  final String scheduledArrival;
  final String estimatedArrival;
  final String statusCheckedAt;

  const Journey({
    required this.mode,
    this.fromCity = '',
    this.toCity = '',
    this.pnr = '',
    this.flightNumber = '',
    this.airline = '',
    this.route = '',
    this.depart = '',
    this.arrive = '',
    this.status = '',
    this.statusNote = '',
    this.departureTerminal = '',
    this.departureGate = '',
    this.arrivalTerminal = '',
    this.arrivalGate = '',
    this.scheduledDeparture = '',
    this.estimatedDeparture = '',
    this.scheduledArrival = '',
    this.estimatedArrival = '',
    this.statusCheckedAt = '',
  });

  Map<String, dynamic> toJson() => {
    'mode': mode.apiValue,
    'from_city': fromCity,
    'to_city': toCity,
    'pnr': pnr,
    'flight_number': flightNumber,
    'airline': airline,
    'route': route,
    'depart': depart,
    'arrive': arrive,
  };

  factory Journey.fromJson(Map<String, dynamic> j) => Journey(
    mode: TransportModeX.fromApi(j['mode'] as String? ?? 'flight'),
    fromCity: j['from_city'] as String? ?? '',
    toCity: j['to_city'] as String? ?? '',
    pnr: j['pnr'] as String? ?? '',
    flightNumber: j['flight_number'] as String? ?? '',
    airline: j['airline'] as String? ?? '',
    route: j['route'] as String? ?? '',
    depart: j['depart'] as String? ?? '',
    arrive: j['arrive'] as String? ?? '',
    status: j['status'] as String? ?? '',
    statusNote: j['status_note'] as String? ?? '',
    departureTerminal: j['departure_terminal'] as String? ?? '',
    departureGate: j['departure_gate'] as String? ?? '',
    arrivalTerminal: j['arrival_terminal'] as String? ?? '',
    arrivalGate: j['arrival_gate'] as String? ?? '',
    scheduledDeparture: j['scheduled_departure'] as String? ?? '',
    estimatedDeparture: j['estimated_departure'] as String? ?? '',
    scheduledArrival: j['scheduled_arrival'] as String? ?? '',
    estimatedArrival: j['estimated_arrival'] as String? ?? '',
    statusCheckedAt: j['status_checked_at'] as String? ?? '',
  );
}

class TripMember {
  final String userId;
  final String name;
  final String role;
  const TripMember({
    required this.userId,
    required this.name,
    required this.role,
  });

  factory TripMember.fromJson(Map<String, dynamic> j) => TripMember(
    userId: j['user_id'] as String? ?? '',
    name: j['name'] as String? ?? '',
    role: j['role'] as String? ?? 'member',
  );
}

class Traveller {
  final String name;
  final int age;
  final String sex; // male | female | other | ''
  final bool isMe;

  const Traveller({
    required this.name,
    this.age = 0,
    this.sex = '',
    this.isMe = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'sex': sex,
    'is_me': isMe,
  };

  factory Traveller.fromJson(Map<String, dynamic> j) => Traveller(
    name: j['name'] as String? ?? '',
    age: (j['age'] as num?)?.toInt() ?? 0,
    sex: j['sex'] as String? ?? '',
    isMe: j['is_me'] as bool? ?? false,
  );
}

class Trip {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final String currency;
  final String coverGradient; // sunset | ocean
  final String inviteCode;
  final String status; // Upcoming | Ongoing | Completed
  final String role; // owner | member
  final String ownerName;
  final List<TripMember> members;
  final List<Destination> destinations;
  final List<Journey> journeys;
  final List<Traveller> travellers;

  const Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.coverGradient,
    required this.inviteCode,
    required this.status,
    required this.role,
    required this.ownerName,
    required this.members,
    required this.destinations,
    required this.journeys,
    this.travellers = const [],
  });

  List<Color> get gradient => coverGradient == 'ocean'
      ? AppColors.gradientOcean
      : AppColors.gradientSunset;

  String get route =>
      destinations.map((d) => d.city).where((c) => c.isNotEmpty).join(' · ');

  factory Trip.fromJson(Map<String, dynamic> j) => Trip(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    startDate: j['start_date'] as String? ?? '',
    endDate: j['end_date'] as String? ?? '',
    currency: j['currency'] as String? ?? 'INR',
    coverGradient: j['cover_gradient'] as String? ?? 'sunset',
    inviteCode: j['invite_code'] as String? ?? '',
    status: j['status'] as String? ?? 'Upcoming',
    role: j['role'] as String? ?? 'member',
    ownerName: j['owner_name'] as String? ?? '',
    members: (j['members'] as List<dynamic>? ?? [])
        .map((m) => TripMember.fromJson(m as Map<String, dynamic>))
        .toList(),
    destinations: (j['destinations'] as List<dynamic>? ?? [])
        .map((d) => Destination.fromJson(d as Map<String, dynamic>))
        .toList(),
    journeys: (j['journeys'] as List<dynamic>? ?? [])
        .map((j2) => Journey.fromJson(j2 as Map<String, dynamic>))
        .toList(),
    travellers: (j['travellers'] as List<dynamic>? ?? [])
        .map((t) => Traveller.fromJson(t as Map<String, dynamic>))
        .toList(),
  );
}
