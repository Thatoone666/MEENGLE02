import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/analytics_service.dart';

/// Stripe payment provider for card and international payments
class StripePaymentProvider {
  static const String _publishableKey = 'pk_live_meengle_key'; // Replace with actual key
  static const String _backendUrl = 'http://localhost:3000/api';

  static Future<void> initialize() async {
    try {
      StripePayment.setOptions(
        StripeOptions(
          publishableKey: _publishableKey,
          merchantId: 'meengle_merchant',
          androidPayMode: 'production',
        ),
      );
      AnalyticsService.logEvent('stripe_initialized', {});
    } catch (e) {
      AnalyticsService.logEvent('stripe_initialization_error', {
        'error': e.toString(),
      });
    }
  }

  /// Create payment intent on backend
  static Future<Map<String, dynamic>?> _createPaymentIntent({
    required double amount,
    required String currency,
    required String tierId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/payments/stripe/intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': currency,
          'tierId': tierId,
          'metadata': {
            'product': 'premium_tier',
            'tier_id': tierId,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  /// Process card payment
  static Future<bool> processCardPayment({
    required double amount,
    required String tierId,
    required String currency,
  }) async {
    try {
      AnalyticsService.logEvent('stripe_card_payment_initiated', {
        'amount': amount,
        'tier_id': tierId,
        'currency': currency,
      });

      // Create payment intent
      final intentData = await _createPaymentIntent(
        amount: amount,
        currency: currency,
        tierId: tierId,
      );

      if (intentData == null) {
        AnalyticsService.logEvent('stripe_intent_creation_failed', {});
        return false;
      }

      // Confirm payment with Stripe
      final result = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: intentData['clientSecret'],
          publishableKey: _publishableKey,
        ),
      );

      if (result.status == StripePaymentStatus.succeeded) {
        AnalyticsService.logEvent('stripe_card_payment_successful', {
          'amount': amount,
          'tier_id': tierId,
          'payment_intent_id': intentData['id'],
        });
        return true;
      }

      AnalyticsService.logEvent('stripe_card_payment_failed', {
        'status': result.status.toString(),
      });
      return false;
    } catch (e) {
      AnalyticsService.logEvent('stripe_card_payment_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get Stripe customer or create new one
  static Future<Map<String, dynamic>?> getOrCreateStripeCustomer({
    required String userEmail,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/payments/stripe/customer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'userId': userId,
          'metadata': {
            'user_id': userId,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting/creating Stripe customer: $e');
      return null;
    }
  }

  /// Get payment method details
  static Future<Map<String, dynamic>?> getPaymentMethodDetails({
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/stripe/method/$paymentMethodId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting payment method: $e');
      return null;
    }
  }
}
