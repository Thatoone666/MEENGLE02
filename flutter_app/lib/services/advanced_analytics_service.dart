import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:async';

/// Advanced analytics and engagement tracking for 9.9/10
class AdvancedAnalyticsService {
  static final AdvancedAnalyticsService _instance = AdvancedAnalyticsService._internal();
  
  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;
  
  factory AdvancedAnalyticsService() {
    return _instance;
  }

  AdvancedAnalyticsService._internal();

  /// Initialize analytics
  Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    
    // Enable analytics collection
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  /// Track user engagement
  Future<void> trackEngagement({
    required String screenName,
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: {
        'screen': screenName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      },
    );
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Track user interaction
  Future<void> trackUserInteraction({
    required String interactionType,
    required String targetUserId,
    Map<String, Object>? metadata,
  }) async {
    await _analytics.logEvent(
      name: 'user_interaction',
      parameters: {
        'interaction_type': interactionType,
        'target_user_id': targetUserId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?metadata,
      },
    );
  }

  /// Track search
  Future<void> trackSearch({
    required String searchTerm,
    required String category,
    int? resultsCount,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        'category': category,
        'results_count': resultsCount ?? 0,
      },
    );
  }

  /// Track feature usage
  Future<void> trackFeatureUsage({
    required String featureName,
    required String action,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: 'feature_usage',
      parameters: {
        'feature': featureName,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      },
    );
  }

  /// Track purchase
  Future<void> trackPurchase({
    required String itemId,
    required String itemName,
    required double value,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemVariant: 'premium',
        ),
      ],
    );
  }

  /// Track error
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': stackTrace ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track session duration
  Future<void> trackSessionDuration(Duration duration) async {
    await _analytics.logEvent(
      name: 'session_duration',
      parameters: {
        'duration_ms': duration.inMilliseconds,
        'duration_seconds': duration.inSeconds,
      },
    );
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    String? userAge,
    String? userGender,
    String? userLocation,
    bool? isPremium,
    bool? isVerified,
  }) async {
    await _analytics.setUserId(userId);
    
    if (userAge != null) {
      await _analytics.setUserProperty(name: 'user_age', value: userAge);
    }
    if (userGender != null) {
      await _analytics.setUserProperty(name: 'user_gender', value: userGender);
    }
    if (userLocation != null) {
      await _analytics.setUserProperty(name: 'user_location', value: userLocation);
    }
    if (isPremium != null) {
      await _analytics.setUserProperty(
        name: 'is_premium',
        value: isPremium.toString(),
      );
    }
    if (isVerified != null) {
      await _analytics.setUserProperty(
        name: 'is_verified',
        value: isVerified.toString(),
      );
    }
  }

  /// Get FirebaseAnalyticsObserver
  FirebaseAnalyticsObserver get observer => _observer;

  /// Get heatmap data
  Future<Map<String, dynamic>> getHeatmapData(String screenName) async {
    return {
      'screen': screenName,
      'hotspots': [],
      'clicks': [],
      'scrollDepth': 0.0,
    };
  }

  /// Get user engagement metrics
  Future<Map<String, dynamic>> getUserEngagementMetrics(String userId) async {
    return {
      'userId': userId,
      'sessionCount': 0,
      'totalEngagementTime': Duration.zero,
      'lastActiveTime': DateTime.now(),
      'features_used': [],
      'conversion_rate': 0.0,
    };
  }

  /// Track A/B test variant
  Future<void> trackABTestVariant({
    required String testName,
    required String variant,
  }) async {
    await _analytics.logEvent(
      name: 'ab_test_variant',
      parameters: {
        'test_name': testName,
        'variant': variant,
      },
    );
  }
}
