import 'package:http/http.dart' as http;
import 'dart:convert';
import './api_service.dart';
import './analytics_service.dart';

/// Service to handle all payment-related operations
class PaymentService {
  static const String _boostPurchaseEndpoint = '/api/payments/boost-purchase';
  static const String _trialEndpoint = '/api/tiers/trial/flame-24hour';
  static const String _freeTrialEndpoint = '/api/payments/free-trial';

  /// Create a 7-day free trial for new users
  static Future<Map<String, dynamic>?> createFreeTrial({
    required String tier,
    required int durationDays,
  }) async {
    try {
      AnalyticsService.logEvent('free_trial_creation_started', {
        'tier': tier,
        'duration_days': durationDays,
      });

      final response = await ApiService.post(
        _freeTrialEndpoint,
        {
          'tier': tier,
          'durationDays': durationDays,
        },
      );

      if (response != null && response['success'] == true) {
        AnalyticsService.logEvent('free_trial_created', {
          'tier': tier,
          'duration_days': durationDays,
          'expires_at': response['expiresAt'],
        });

        return {
          'success': true,
          'tier': tier,
          'expiresAt': response['expiresAt'],
          'durationDays': durationDays,
        };
      } else {
        AnalyticsService.logEvent('free_trial_creation_failed', {
          'error': response?['error'] ?? 'Unknown error',
        });
        return null;
      }
    } catch (e) {
      AnalyticsService.logEvent('free_trial_creation_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Purchase a boost offer
  static Future<Map<String, dynamic>?> purchaseBoost({
    required String boostId,
    required double price,
  }) async {
    try {
      AnalyticsService.logEvent('boost_purchase_initiated', {
        'boost_id': boostId,
        'price': price,
      });

      final response = await ApiService.post(
        _boostPurchaseEndpoint,
        {
          'boostId': boostId,
          'price': price,
          'currency': 'USD',
        },
      );

      if (response != null && response['success'] == true) {
        AnalyticsService.logEvent('boost_purchase_successful', {
          'boost_id': boostId,
          'price': price,
          'transaction_id': response['transactionId'],
        });

        return {
          'success': true,
          'transaction_id': response['transactionId'],
          'boost_id': boostId,
          'amount_paid': price,
        };
      } else {
        AnalyticsService.logEvent('boost_purchase_failed', {
          'boost_id': boostId,
          'error': response?['error'] ?? 'Purchase failed',
        });
        return null;
      }
    } catch (e) {
      AnalyticsService.logEvent('boost_purchase_error', {
        'boost_id': boostId,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Start 24-hour trial on account deletion prevention
  static Future<Map<String, dynamic>?> startDeletionPreventionTrial() async {
    try {
      AnalyticsService.logEvent('deletion_prevention_trial_started', {});

      final response = await ApiService.post(
        _trialEndpoint,
        {},
      );

      if (response != null && response['success'] == true) {
        AnalyticsService.logEvent('deletion_prevention_trial_activated', {
          'tier': response['tier'],
          'expires_at': response['expiresAt'],
        });

        return {
          'success': true,
          'tier': response['tier'],
          'expiresAt': response['expiresAt'],
        };
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('deletion_prevention_trial_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get user's current subscription status
  static Future<Map<String, dynamic>?> getUserSubscription() async {
    try {
      final response = await ApiService.get('/api/tiers/user/current');

      if (response != null && response['success'] == true) {
        return {
          'subscription': response['subscription'],
          'tierInfo': response['tierInfo'],
        };
      }

      return null;
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }

  /// Upgrade to a premium tier
  static Future<bool> upgradeTier({
    required String newTier,
    required String billingCycle,
  }) async {
    try {
      AnalyticsService.logEvent('tier_upgrade_initiated', {
        'new_tier': newTier,
        'billing_cycle': billingCycle,
      });

      final response = await ApiService.post(
        '/api/tiers/create-checkout',
        {
          'tierId': newTier,
          'billingCycle': billingCycle,
        },
      );

      if (response != null && response['success'] == true) {
        AnalyticsService.logEvent('tier_upgrade_checkout_created', {
          'new_tier': newTier,
          'billing_cycle': billingCycle,
          'session_id': response['sessionId'],
        });

        // In a real app, this would open the Stripe checkout session
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('tier_upgrade_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Cancel current subscription
  static Future<bool> cancelSubscription() async {
    try {
      AnalyticsService.logEvent('subscription_cancellation_initiated', {});

      final response = await ApiService.post('/api/tiers/cancel', {});

      if (response != null && response['success'] == true) {
        AnalyticsService.logEvent('subscription_cancelled', {});
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('subscription_cancellation_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get available tiers and pricing
  static Future<Map<String, dynamic>?> getAvailableTiers() async {
    try {
      final response = await ApiService.get('/api/tiers');

      if (response != null && response['success'] == true) {
        return response['tiers'];
      }

      return null;
    } catch (e) {
      print('Error getting tiers: $e');
      return null;
    }
  }

  /// Check trial status
  static Future<Map<String, dynamic>?> checkTrialStatus() async {
    try {
      final response = await ApiService.get('/api/tiers/trial/status');

      if (response != null && response['success'] == true) {
        return {
          'isTrialing': response['isTrialing'],
          'tier': response['tier'],
          'hoursRemaining': response['hoursRemaining'],
          'expiresAt': response['expiresAt'],
        };
      }

      return null;
    } catch (e) {
      print('Error checking trial status: $e');
      return null;
    }
  }
}
