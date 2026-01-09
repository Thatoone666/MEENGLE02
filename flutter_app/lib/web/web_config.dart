import 'package:flutter/foundation.dart';

class WebConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.meengle.com',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE',
    defaultValue: '',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'wss://api.meengle.com',
  );

  static const String cdnUrl = String.fromEnvironment(
    'CDN_URL',
    defaultValue: 'https://cdn.meengle.com',
  );

  static void logError(dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
    }
    // In production, you might want to send this to a logging service
  }

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'X-Platform': 'web',
    'X-Version': '1.0.0',
  };

  static Duration get defaultTimeout => const Duration(seconds: 30);

  static int get maxUploadSizeMb => 10;

  static bool get enableAnalytics => const bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  static String get environment => const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );
}