import 'package:http/http.dart' as http;
import 'dart:convert';
import '../analytics_service.dart';

/// Zapper payment provider - Instant bank transfer platform
/// Zapper supports instant EFT transfers with multiple bank options
class ZapperPaymentProvider {
  static const String _apiKey = 'api_key_meengle_zapper'; // Replace with actual key
  static const String _backendUrl = 'http://localhost:3000/api';
  static const String _zapperApiUrl = 'https://api.zapper.co.za';

  /// Create Zapper payment request
  static Future<Map<String, dynamic>?> createPaymentRequest({
    required double amount,
    required String tierId,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      AnalyticsService.logEvent('zapper_payment_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/zapper/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'phoneNumber': phoneNumber,
          'description': 'Meengle Premium Subscription',
          'redirectUrl': 'https://meengle.app/payment-success',
          'errorUrl': 'https://meengle.app/payment-error',
          'metadata': {
            'tier_id': tierId,
            'product': 'premium_tier',
            'user_email': email,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('zapper_payment_created', {
          'request_id': data['requestId'],
          'redirect_url': data['redirectUrl'],
        });
        return data;
      }

      AnalyticsService.logEvent('zapper_payment_failed', {
        'error': response.body,
      });
      return null;
    } catch (e) {
      AnalyticsService.logEvent('zapper_payment_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get supported banks
  static Future<List<Map<String, dynamic>>?> getSupportedBanks() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/zapper/banks'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['banks']);
      }

      return null;
    } catch (e) {
      print('Error getting Zapper banks: $e');
      return null;
    }
  }

  /// Check payment status
  static Future<Map<String, dynamic>?> getPaymentStatus({
    required String requestId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/zapper/status/$requestId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting Zapper payment status: $e');
      return null;
    }
  }

  /// Create recurring payment
  static Future<Map<String, dynamic>?> createRecurringPayment({
    required double amount,
    required String tierId,
    required String email,
    required String bankId,
    required String frequency,
  }) async {
    try {
      AnalyticsService.logEvent('zapper_recurring_initiated', {
        'amount': amount,
        'tier_id': tierId,
        'frequency': frequency,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/zapper/recurring'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'bankId': bankId,
          'frequency': frequency,
          'description': 'Meengle Premium Subscription',
          'metadata': {
            'tier_id': tierId,
            'recurring': true,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('zapper_recurring_created', {
          'agreement_id': data['agreementId'],
          'frequency': frequency,
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('zapper_recurring_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Cancel recurring payment
  static Future<bool> cancelRecurringPayment({
    required String agreementId,
  }) async {
    try {
      AnalyticsService.logEvent('zapper_recurring_cancel_initiated', {
        'agreement_id': agreementId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/zapper/recurring/$agreementId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': 'user_request'}),
      );

      if (response.statusCode == 200) {
        AnalyticsService.logEvent('zapper_recurring_cancelled', {
          'agreement_id': agreementId,
        });
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('zapper_recurring_cancel_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get transaction history
  static Future<List<Map<String, dynamic>>?> getTransactionHistory({
    required String email,
    required int limit,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/zapper/history?email=$email&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions']);
      }

      return null;
    } catch (e) {
      print('Error getting Zapper transaction history: $e');
      return null;
    }
  }
}
