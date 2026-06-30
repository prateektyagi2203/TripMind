import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Activity categories returned by the planner / places API.
enum ActivityCategory {
  food,
  sightseeing,
  nature,
  culture,
  relax,
  shopping,
  transit,
  nightlife,
  other,
}

extension ActivityCategoryX on ActivityCategory {
  String get apiValue => name;

  String get label => switch (this) {
    ActivityCategory.food => 'Food',
    ActivityCategory.sightseeing => 'Sightseeing',
    ActivityCategory.nature => 'Nature',
    ActivityCategory.culture => 'Culture',
    ActivityCategory.relax => 'Relax',
    ActivityCategory.shopping => 'Shopping',
    ActivityCategory.transit => 'Transit',
    ActivityCategory.nightlife => 'Nightlife',
    ActivityCategory.other => 'Other',
  };

  IconData get icon => switch (this) {
    ActivityCategory.food => Icons.restaurant_rounded,
    ActivityCategory.sightseeing => Icons.photo_camera_rounded,
    ActivityCategory.nature => Icons.park_rounded,
    ActivityCategory.culture => Icons.museum_rounded,
    ActivityCategory.relax => Icons.spa_rounded,
    ActivityCategory.shopping => Icons.shopping_bag_rounded,
    ActivityCategory.transit => Icons.directions_transit_rounded,
    ActivityCategory.nightlife => Icons.nightlife_rounded,
    ActivityCategory.other => Icons.place_rounded,
  };

  Color get color => switch (this) {
    ActivityCategory.food => AppColors.sunset,
    ActivityCategory.nightlife => AppColors.sunset,
    ActivityCategory.nature => AppColors.ocean,
    ActivityCategory.relax => AppColors.ocean,
    _ => AppColors.primary,
  };

  static ActivityCategory fromApi(String v) => ActivityCategory.values
      .firstWhere((c) => c.name == v, orElse: () => ActivityCategory.other);
}

class Activity {
  final String time;
  final String title;
  final String description;
  final ActivityCategory category;
  final String locationName;
  final String locationAddress;
  final String lat;
  final String lng;
  final String source; // ai | user | places
  final String rating;
  final String link;
  final String imageUrl;

  const Activity({
    this.time = '',
    required this.title,
    this.description = '',
    this.category = ActivityCategory.other,
    this.locationName = '',
    this.locationAddress = '',
    this.lat = '',
    this.lng = '',
    this.source = 'user',
    this.rating = '',
    this.link = '',
    this.imageUrl = '',
  });

  Activity copyWith({
    String? time,
    String? title,
    String? description,
    ActivityCategory? category,
    String? locationName,
    String? locationAddress,
  }) => Activity(
    time: time ?? this.time,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    locationName: locationName ?? this.locationName,
    locationAddress: locationAddress ?? this.locationAddress,
    lat: lat,
    lng: lng,
    source: source,
    rating: rating,
    link: link,
    imageUrl: imageUrl,
  );

  Map<String, dynamic> toJson() => {
    'time': time,
    'title': title,
    'description': description,
    'category': category.apiValue,
    'location_name': locationName,
    'location_address': locationAddress,
    'lat': lat,
    'lng': lng,
    'source': source,
    'rating': rating,
    'link': link,
    'image_url': imageUrl,
  };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
    time: j['time'] as String? ?? '',
    title: j['title'] as String? ?? '',
    description: j['description'] as String? ?? '',
    category: ActivityCategoryX.fromApi(j['category'] as String? ?? 'other'),
    locationName: j['location_name'] as String? ?? '',
    locationAddress: j['location_address'] as String? ?? '',
    lat: j['lat'] as String? ?? '',
    lng: j['lng'] as String? ?? '',
    source: j['source'] as String? ?? 'ai',
    rating: j['rating'] as String? ?? '',
    link: j['link'] as String? ?? '',
    imageUrl: j['image_url'] as String? ?? '',
  );
}

class ItineraryDay {
  final String id;
  final int dayIndex;
  final String date;
  final String title;
  final String area;
  final String summary;
  final bool isLight;
  final List<Activity> activities;

  const ItineraryDay({
    this.id = '',
    required this.dayIndex,
    this.date = '',
    this.title = '',
    this.area = '',
    this.summary = '',
    this.isLight = false,
    this.activities = const [],
  });

  ItineraryDay copyWith({
    String? title,
    bool? isLight,
    List<Activity>? activities,
  }) => ItineraryDay(
    id: id,
    dayIndex: dayIndex,
    date: date,
    title: title ?? this.title,
    area: area,
    summary: summary,
    isLight: isLight ?? this.isLight,
    activities: activities ?? this.activities,
  );

  Map<String, dynamic> toJson() => {
    'day_index': dayIndex,
    'date': date,
    'title': title,
    'area': area,
    'summary': summary,
    'is_light': isLight,
    'activities': activities.map((a) => a.toJson()).toList(),
  };

  factory ItineraryDay.fromJson(Map<String, dynamic> j) => ItineraryDay(
    id: j['id'] as String? ?? '',
    dayIndex: (j['day_index'] as num?)?.toInt() ?? 0,
    date: j['date'] as String? ?? '',
    title: j['title'] as String? ?? '',
    area: j['area'] as String? ?? '',
    summary: j['summary'] as String? ?? '',
    isLight: j['is_light'] as bool? ?? false,
    activities: (j['activities'] as List<dynamic>? ?? [])
        .map((a) => Activity.fromJson(a as Map<String, dynamic>))
        .toList(),
  );
}

class ItineraryPlan {
  final String tripId;
  final List<ItineraryDay> days;

  const ItineraryPlan({required this.tripId, this.days = const []});

  bool get isEmpty => days.isEmpty;

  factory ItineraryPlan.fromJson(Map<String, dynamic> j) => ItineraryPlan(
    tripId: j['trip_id'] as String? ?? '',
    days: (j['days'] as List<dynamic>? ?? [])
        .map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
        .toList(),
  );
}

class PlanPreferences {
  final String pace; // light | balanced | packed
  final List<String> interests;
  final bool keepFirstDayLight;
  final String travelers;
  final String notes;

  const PlanPreferences({
    this.pace = 'balanced',
    this.interests = const [],
    this.keepFirstDayLight = true,
    this.travelers = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'pace': pace,
    'interests': interests,
    'keep_first_day_light': keepFirstDayLight,
    'travelers': travelers,
    'notes': notes,
  };
}

class NearbyPlace {
  final String name;
  final String address;
  final String lat;
  final String lng;
  final String rating;
  final String link;
  final String imageUrl;
  final ActivityCategory category;

  const NearbyPlace({
    required this.name,
    this.address = '',
    this.lat = '',
    this.lng = '',
    this.rating = '',
    this.link = '',
    this.imageUrl = '',
    this.category = ActivityCategory.other,
  });

  Activity toActivity() => Activity(
    title: name,
    category: category,
    locationName: name,
    locationAddress: address,
    lat: lat,
    lng: lng,
    source: 'places',
    rating: rating,
    link: link,
    imageUrl: imageUrl,
  );

  factory NearbyPlace.fromJson(Map<String, dynamic> j) => NearbyPlace(
    name: j['name'] as String? ?? '',
    address: j['address'] as String? ?? '',
    lat: j['lat'] as String? ?? '',
    lng: j['lng'] as String? ?? '',
    rating: j['rating'] as String? ?? '',
    link: j['link'] as String? ?? '',
    imageUrl: j['image_url'] as String? ?? '',
    category: ActivityCategoryX.fromApi(j['category'] as String? ?? 'other'),
  );
}
