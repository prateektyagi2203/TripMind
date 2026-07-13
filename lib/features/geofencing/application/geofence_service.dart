import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'geofence_callback.dart';
import 'geofence_notifications.dart';

/// Registers native OS-level geofences (survive app termination + reboot)
/// for a trip's Day 1 arrival: one around the arrival airport (proxy for
/// "you've reached the country" — a real border isn't a practical circular
/// region) and one around the Day 1 hotel. Firing is handled entirely by
/// [onGeofenceEvent] reading the context this class writes to SharedPreferences.
class GeofenceService {
  static const _airportRadiusMeters = 5000.0;
  static const _hotelRadiusMeters = 200.0;

  /// native_geofence only ships Android + iOS platform implementations —
  /// calling it on web/desktop throws MissingPluginException.
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (!isSupported) return;
    await NativeGeofenceManager.instance.initialize();
    await GeofenceNotifications.init();
  }

  /// Requests location (when-in-use, then always) + notification permission.
  /// Returns true only if background ("always") location was granted — that's
  /// what's required for greetings to fire while the app isn't running.
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    final whenInUse = await Permission.locationWhenInUse.request();
    if (!whenInUse.isGranted) return false;
    await Permission.notification.request();
    final always = await Permission.locationAlways.request();
    return always.isGranted;
  }

  Future<bool> hasAlwaysLocationPermission() async {
    if (!isSupported) return false;
    return Permission.locationAlways.status.then((s) => s.isGranted);
  }

  /// Registers this trip's two geofences, replacing any previously registered
  /// trip's (keeps well under iOS's 20-region cap — this app only tracks one
  /// active trip's arrival at a time). No-ops if already synced for [tripId].
  Future<void> syncTripGeofences({
    required String tripId,
    required String countryName,
    required double airportLat,
    required double airportLng,
    required String hotelName,
    required double hotelLat,
    required double hotelLng,
    String? tomorrowTime,
    String? tomorrowActivity,
  }) async {
    if (!isSupported) return;
    final prefs = await SharedPreferences.getInstance();
    final syncedKey = 'geofence_synced_$tripId';
    if (prefs.getBool(syncedKey) == true) return;

    await NativeGeofenceManager.instance.removeAllGeofences();

    final countryId = 'country_$tripId';
    final hotelId = 'hotel_$tripId';

    await prefs.setString(
      '$geofenceContextPrefsPrefix$countryId',
      jsonEncode({'type': 'country', 'name': countryName}),
    );
    await prefs.setString(
      '$geofenceContextPrefsPrefix$hotelId',
      jsonEncode({
        'type': 'hotel',
        'name': hotelName,
        'nextTime': tomorrowTime ?? '',
        'nextActivity': tomorrowActivity ?? '',
      }),
    );

    try {
      await NativeGeofenceManager.instance.createGeofence(
        Geofence(
          id: countryId,
          location: Location(latitude: airportLat, longitude: airportLng),
          radiusMeters: _airportRadiusMeters,
          triggers: const {GeofenceEvent.enter},
          iosSettings: const IosGeofenceSettings(),
          androidSettings: const AndroidGeofenceSettings(initialTriggers: {}),
        ),
        onGeofenceEvent,
      );
      await NativeGeofenceManager.instance.createGeofence(
        Geofence(
          id: hotelId,
          location: Location(latitude: hotelLat, longitude: hotelLng),
          radiusMeters: _hotelRadiusMeters,
          triggers: const {GeofenceEvent.enter},
          iosSettings: const IosGeofenceSettings(),
          androidSettings: const AndroidGeofenceSettings(initialTriggers: {}),
        ),
        onGeofenceEvent,
      );
      await prefs.setBool(syncedKey, true);
    } on NativeGeofenceException catch (e, s) {
      debugPrint('Failed to register arrival geofences: ${e.code} ${e.message}');
      debugPrintStack(stackTrace: s);
    }
  }
}

final geofenceServiceProvider = Provider<GeofenceService>((ref) => GeofenceService());
