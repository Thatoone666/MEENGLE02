import 'package:http/http.dart' as http;
import 'dart:convert';
import '../analytics_service.dart';

/// Yoco payment provider - South African card and banking solution
/// Yoco supports: Credit/Debit cards, banking apps (instant EFT), savings accounts
class YocoPaymentProvider {
  static const String _publicKey = 'pk_live_meengle_yoco'; // Replace with actual key
  static const String _backendUrl = 'http://localhost:3000/api';
  static const String _yocoApiUrl = 'https://api.yoco.com/v1';

  /// Create Yoco charge for card payment
  static Future<Map<String, dynamic>?> createCharge({
    required double amount,
    required String tierId,
    required String token,
    required String email,
  }) async {
    try {
      AnalyticsService.logEvent('yoco_charge_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/yoco/charge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (amount * 100).toInt(), // Convert to cents
          'tierId': tierId,
          'token': token,
          'email': email,
          'description': 'Meengle Premium Subscription',
          'metadata': {
            'user_email': email,
            'tier_id': tierId,
            'product': 'premium_tier',
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('yoco_charge_successful', {
          'transaction_id': data['id'],
          'amount': amount,
        });
        return data;
      }

      AnalyticsService.logEvent('yoco_charge_failed', {
        'status_code': response.statusCode,
        'error': response.body,
      });
      return null;
    } catch (e) {
      AnalyticsService.logEvent('yoco_charge_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create tokenized payment method for recurring charges
  static Future<Map<String, dynamic>?> createPaymentMethod({
    required String token,
    required String email,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/payments/yoco/payment-method'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'email': email,
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
      print('Error creating Yoco payment method: $e');
      return null;
    }
  }

  /// Create subscription with recurring charges
  static Future<Map<String, dynamic>?> createSubscription({
    required String paymentMethodId,
    required double amount,
    required String tierId,
    required String email,
  }) async {
    try {
      AnalyticsService.logEvent('yoco_subscription_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/yoco/subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentMethodId': paymentMethodId,
          'amount': (amount * 100).toInt(),
          'tierId': tierId,
          'email': email,
          'description': 'Meengle Premium Subscription',
          'recurringPayment': {
            'interval': 'monthly',
            'intervalCount': 1,
          },
          'metadata': {
            'user_email': email,
            'tier_id': tierId,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('yoco_subscription_created', {
          'subscription_id': data['id'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('yoco_subscription_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get transaction details
  static Future<Map<String, dynamic>?> getTransaction({
    required String transactionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/yoco/transaction/$transactionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting Yoco transaction: $e');
      return null;
    }
  }

  /// Refund transaction
  static Future<bool> refundTransaction({
    required String transactionId,
    required double amount,
  }) async {
    try {
      AnalyticsService.logEvent('yoco_refund_initiated', {
        'transaction_id': transactionId,
        'amount': amount,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/yoco/refund'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'transactionId': transactionId,
          'amount': (amount * 100).toInt(),
          'reason': 'subscription_cancellation',
        }),
      );

      if (response.statusCode == 200) {
        AnalyticsService.logEvent('yoco_refund_successful', {
          'transaction_id': transactionId,
        });
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('yoco_refund_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Verify 3D Secure (for enhanced security)
  static Future<bool> verify3DSecure({
    required String transactionId,
    required String authenticationCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/payments/yoco/verify-3ds'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'transactionId': transactionId,
          'authenticationCode': authenticationCode,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying 3DS: $e');
      return false;
    }
  }
}
