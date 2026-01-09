import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/meengle_tier_system.dart';

/// Comprehensive analytics tracking for revenue metrics
class RevenueAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ===== PAYWALL EVENTS =====

  /// Track paywall impression (shown to user)
  static Future<void> trackPaywallShown({
    required String featureId,
    required MeengleTier requiredTier,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'paywall_shown',
      parameters: {
        'feature_id': featureId,
        'required_tier': requiredTier.displayName,
        'source': source,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track paywall click (user tapped upgrade)
  static Future<void> trackPaywallClicked({
    required String featureId,
    required MeengleTier requiredTier,
    required String action,
  }) async {
    await _analytics.logEvent(
      name: 'paywall_clicked',
      parameters: {
        'feature_id': featureId,
        'required_tier': requiredTier.displayName,
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track paywall dismissal
  static Future<void> trackPaywallDismissed({
    required String featureId,
    required MeengleTier requiredTier,
    required int timeViewedSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'paywall_dismissed',
      parameters: {
        'feature_id': featureId,
        'required_tier': requiredTier.displayName,
        'time_viewed_seconds': timeViewedSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== CONVERSION FUNNEL =====

  /// Track user arrives at tier upgrade screen
  static Future<void> trackUpgradeScreenViewed({
    required MeengleTier currentTier,
    required MeengleTier targetTier,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'upgrade_screen_viewed',
      parameters: {
        'current_tier': currentTier.displayName,
        'target_tier': targetTier.displayName,
        'source': source,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track user starts checkout
  static Future<void> trackCheckoutStarted({
    required String tier,
    required String billingCycle,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'checkout_started',
      parameters: {
        'tier': tier,
        'billing_cycle': billingCycle,
        'price': price,
        'currency': 'USD',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track successful purchase
  static Future<void> trackPurchaseCompleted({
    required String tier,
    required String billingCycle,
    required double price,
    required String transactionId,
  }) async {
    await _analytics.logEvent(
      name: 'purchase_completed',
      parameters: {
        'tier': tier,
        'billing_cycle': billingCycle,
        'price': price,
        'currency': 'USD',
        'transaction_id': transactionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track purchase failed
  static Future<void> trackPurchaseFailed({
    required String tier,
    required String billingCycle,
    required String errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'purchase_failed',
      parameters: {
        'tier': tier,
        'billing_cycle': billingCycle,
        'error': errorMessage,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== TRIAL EVENTS =====

  /// Track free trial started
  static Future<void> trackTrialStarted({
    required String trialType,
    required int durationDays,
    required String? userGoal,
  }) async {
    await _analytics.logEvent(
      name: 'trial_started',
      parameters: {
        'trial_type': trialType,
        'duration_days': durationDays,
        'user_goal': userGoal ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track trial converted to paid
  static Future<void> trackTrialConverted({
    required String trialType,
    required String newTier,
    required String billingCycle,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'trial_converted',
      parameters: {
        'trial_type': trialType,
        'new_tier': newTier,
        'billing_cycle': billingCycle,
        'price': price,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track trial expired without conversion
  static Future<void> trackTrialExpired({
    required String trialType,
  }) async {
    await _analytics.logEvent(
      name: 'trial_expired',
      parameters: {
        'trial_type': trialType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== BOOST EVENTS =====

  /// Track boost offer shown
  static Future<void> trackBoostOfferShown({
    required String boostId,
    required String trigger,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'boost_offer_shown',
      parameters: {
        'boost_id': boostId,
        'trigger': trigger,
        'price': price,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track boost offer accepted
  static Future<void> trackBoostOfferAccepted({
    required String boostId,
    required String trigger,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'boost_offer_accepted',
      parameters: {
        'boost_id': boostId,
        'trigger': trigger,
        'price': price,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track boost purchased
  static Future<void> trackBoostPurchased({
    required String boostId,
    required double price,
    required String trigger,
  }) async {
    await _analytics.logEvent(
      name: 'boost_purchased',
      parameters: {
        'boost_id': boostId,
        'price': price,
        'trigger': trigger,
        'currency': 'USD',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== ACCOUNT DELETION EVENTS =====

  /// Track deletion prevention retention offer shown
  static Future<void> trackDeletionRetentionOffered({
    required int daysActive,
  }) async {
    await _analytics.logEvent(
      name: 'deletion_retention_offered',
      parameters: {
        'days_active': daysActive,
        'offer_type': 'flame_24hour_trial',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track deletion retention offer accepted
  static Future<void> trackDeletionRetentionAccepted({
    required int daysActive,
  }) async {
    await _analytics.logEvent(
      name: 'deletion_retention_accepted',
      parameters: {
        'days_active': daysActive,
        'offer_type': 'flame_24hour_trial',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track user proceeded with deletion despite retention offer
  static Future<void> trackUserDeletedAccount({
    required int daysActive,
  }) async {
    await _analytics.logEvent(
      name: 'account_deleted',
      parameters: {
        'days_active': daysActive,
        'retention_offered': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== REVENUE METRICS =====

  /// Track subscription renewal
  static Future<void> trackSubscriptionRenewal({
    required String tier,
    required String billingCycle,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_renewed',
      parameters: {
        'tier': tier,
        'billing_cycle': billingCycle,
        'price': price,
        'currency': 'USD',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track subscription cancelled
  static Future<void> trackSubscriptionCancelled({
    required String tier,
    required int monthsSubscribed,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_cancelled',
      parameters: {
        'tier': tier,
        'months_subscribed': monthsSubscribed,
        'reason': reason,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ===== CONVERSION FUNNEL TRACKING =====

  /// Build complete conversion funnel tracking
  static class ConversionFunnel {
    static const String funnelName = 'paywall_to_purchase';

    static const Map<int, String> stages = {
      1: 'paywall_shown',
      2: 'paywall_clicked',
      3: 'tier_screen_viewed',
      4: 'checkout_started',
      5: 'purchase_completed',
    };

    /// Log user progression through funnel
    static Future<void> logFunnelStep({
      required int stepNumber,
      required Map<String, dynamic> parameters,
    }) async {
      final stepName = stages[stepNumber] ?? 'unknown_step';
      parameters['funnel_name'] = funnelName;
      parameters['step_number'] = stepNumber;
      parameters['timestamp'] = DateTime.now().millisecondsSinceEpoch;

      await FirebaseAnalytics.instance.logEvent(
        name: stepName,
        parameters: parameters,
      );
    }
  }
}
