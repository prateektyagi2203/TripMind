import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a ride-hailing app for the Day 1 airport -> hotel leg.
///
/// Grab's pickup/dropoff deep-link parameters are officially documented and
/// reliable. Bolt and inDrive don't publish a stable public deep-link
/// contract for pre-filling a route, so for those we only attempt to open
/// the app itself — falling back to the store listing when it isn't
/// installed (or when running on a platform, like this macOS dev build,
/// where none of these apps exist at all).
Future<bool> openRideApp(
  String provider, {
  required double pickupLat,
  required double pickupLng,
  required double dropoffLat,
  required double dropoffLng,
  String pickupLabel = '',
  String dropoffLabel = '',
}) async {
  final scheme = _schemeUri(
    provider,
    pickupLat: pickupLat,
    pickupLng: pickupLng,
    dropoffLat: dropoffLat,
    dropoffLng: dropoffLng,
    pickupLabel: pickupLabel,
    dropoffLabel: dropoffLabel,
  );
  if (scheme != null && await canLaunchUrl(scheme)) {
    return launchUrl(scheme, mode: LaunchMode.externalApplication);
  }
  final fallback = _storeFallback(provider);
  if (fallback != null) {
    return launchUrl(fallback, mode: LaunchMode.externalApplication);
  }
  return false;
}

Uri? _schemeUri(
  String provider, {
  required double pickupLat,
  required double pickupLng,
  required double dropoffLat,
  required double dropoffLng,
  required String pickupLabel,
  required String dropoffLabel,
}) {
  switch (provider.toLowerCase()) {
    case 'grab':
      return Uri(
        scheme: 'grab',
        host: 'open',
        queryParameters: {
          'screenType': 'BOOKING',
          'pickUpLatitude': '$pickupLat',
          'pickUpLongitude': '$pickupLng',
          if (pickupLabel.isNotEmpty) 'pickUpAddress': pickupLabel,
          'dropOffLatitude': '$dropoffLat',
          'dropOffLongitude': '$dropoffLng',
          if (dropoffLabel.isNotEmpty) 'dropOffAddress': dropoffLabel,
        },
      );
    case 'bolt':
      // Bolt has no publicly documented route pre-fill contract; just open the app.
      return Uri.parse('bolt://');
    case 'indrive':
      // inDrive has no publicly documented route pre-fill contract; just open the app.
      return Uri.parse('indriver://');
    default:
      return null;
  }
}

Uri? _storeFallback(String provider) {
  // Default to the iOS link off-Android (matches AppConfig's platform check style).
  final ios = defaultTargetPlatform != TargetPlatform.android;
  switch (provider.toLowerCase()) {
    case 'grab':
      return Uri.parse(
        ios
            ? 'https://apps.apple.com/app/grab-taxi-food-delivery/id647268330'
            : 'https://play.google.com/store/apps/details?id=com.grabtaxi.passenger',
      );
    case 'bolt':
      return Uri.parse(
        ios
            ? 'https://apps.apple.com/app/bolt-request-a-ride/id675033630'
            : 'https://play.google.com/store/apps/details?id=ee.mtakso.client',
      );
    case 'indrive':
      return Uri.parse(
        ios
            ? 'https://apps.apple.com/app/indrive-your-way-to-ride/id780125200'
            : 'https://play.google.com/store/apps/details?id=sinet.startup.inDriver',
      );
    default:
      return null;
  }
}
