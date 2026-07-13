import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/greeting_templates.dart';
import 'geofence_notifications.dart';

const geofenceContextPrefsPrefix = 'geofence_ctx_';

/// Top-level entry point native_geofence invokes (in a background isolate,
/// possibly after the app was fully terminated) when a registered region is
/// entered. Must not depend on any app/provider state — only SharedPreferences,
/// which [GeofenceService] populates when it registers each geofence.
@pragma('vm:entry-point')
Future<void> onGeofenceEvent(GeofenceCallbackParams params) async {
  if (params.event != GeofenceEvent.enter) return;

  final prefs = await SharedPreferences.getInstance();

  for (final geofence in params.geofences) {
    final raw = prefs.getString('$geofenceContextPrefsPrefix${geofence.id}');
    if (raw == null) continue;
    try {
      final ctx = jsonDecode(raw) as Map<String, dynamic>;
      final type = ctx['type'] as String? ?? '';
      final name = ctx['name'] as String? ?? '';
      if (name.isEmpty) continue;

      String title;
      String message;
      if (type == 'country') {
        title = 'Welcome to $name!';
        message = GreetingTemplates.countryArrival(name);
      } else if (type == 'hotel') {
        title = 'You\'ve reached $name';
        message = GreetingTemplates.hotelArrival(
          name,
          nextTime: ctx['nextTime'] as String?,
          nextActivity: ctx['nextActivity'] as String?,
        );
      } else {
        continue;
      }

      await GeofenceNotifications.showArrivalGreeting(title, message);
      // Fire once per arrival — don't re-greet on every re-entry.
      await NativeGeofenceManager.instance.removeGeofenceById(geofence.id);
      await prefs.remove('$geofenceContextPrefsPrefix${geofence.id}');
    } catch (e, s) {
      debugPrint('onGeofenceEvent failed for ${geofence.id}: $e');
      debugPrintStack(stackTrace: s);
    }
  }
}
