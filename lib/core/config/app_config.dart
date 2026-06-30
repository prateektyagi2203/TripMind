import 'package:flutter/foundation.dart';

/// App configuration. The API base URL can be overridden at build time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
abstract class AppConfig {
  static const _override = String.fromEnvironment('API_BASE_URL');

  /// Base URL for the FastAPI backend.
  ///
  /// Defaults are platform-aware for local development:
  /// - Android emulator reaches the host machine via 10.0.2.2
  /// - Web / desktop / iOS simulator use 127.0.0.1
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }
}
