import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows the arrival-greeting local notification. Safe to call from the
/// background isolate the geofence callback runs in — re-initializes the
/// plugin each time since that isolate starts fresh.
class GeofenceNotifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      _initialized = true;
    } catch (e, s) {
      debugPrint('GeofenceNotifications init failed: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  static Future<void> showArrivalGreeting(String title, String message) async {
    if (!_initialized) await init();
    try {
      await _plugin.show(
        id: title.hashCode & 0x7fffffff,
        title: title,
        body: message,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'arrival_greetings',
            'Arrival Greetings',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(message),
          ),
          iOS: const DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
      );
    } catch (e, s) {
      debugPrint('GeofenceNotifications show failed: $e');
      debugPrintStack(stackTrace: s);
    }
  }
}
