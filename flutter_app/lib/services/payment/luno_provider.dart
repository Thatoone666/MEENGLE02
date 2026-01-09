import 'package:http/http.dart' as http;
import 'dart:convert';
import '../analytics_service.dart';

/// Luno payment provider - Bitcoin and cryptocurrency payments
/// Luno enables Bitcoin payments in ZAR with instant settlement
class LunoPaymentProvider {
  static const String _apiKey = 'api_key_meengle_luno'; // Replace with actual key
  static const String _backendUrl = 'http://localhost:3000/api';
  static const String _lunoApiUrl = 'https://api.myc.co.za';

  /// Create Bitcoin invoice
  static Future<Map<String, dynamic>?> createBitcoinInvoice({
    required double amountInZar,
    required String tierId,
    required String email,
  }) async {
    try {
      AnalyticsService.logEvent('luno_invoice_initiated', {
        'amount_zar': amountInZar,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/luno/invoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amountInZar': amountInZar,
          'tierId': tierId,
          'email': email,
          'description': 'Meengle Premium Subscription',
          'notificationUrl': 'https://meengle.app/api/webhooks/luno',
          'returnUrl': 'https://meengle.app/payment-success',
          'cancelUrl': 'https://meengle.app/payment-cancel',
          'metadata': {
            'tier_id': tierId,
            'product': 'premium_tier',
            'user_email': email,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('luno_invoice_created', {
          'invoice_id': data['invoiceId'],
          'bitcoin_address': data['bitcoinAddress'],
          'amount_btc': data['amountBtc'],
          'exchange_rate': data['exchangeRate'],
        });
        return data;
      }

      AnalyticsService.logEvent('luno_invoice_failed', {
        'error': response.body,
      });
      return null;
    } catch (e) {
      AnalyticsService.logEvent('luno_invoice_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get current Bitcoin exchange rate
  static Future<Map<String, dynamic>?> getExchangeRate() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/luno/rate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting Luno exchange rate: $e');
      return null;
    }
  }

  /// Check invoice status
  static Future<Map<String, dynamic>?> getInvoiceStatus({
    required String invoiceId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/luno/invoice/$invoiceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting Luno invoice status: $e');
      return null;
    }
  }

  /// Create payment request (alternative to invoice)
  static Future<Map<String, dynamic>?> createPaymentRequest({
    required double amountInBtc,
    required String tierId,
    required String email,
  }) async {
    try {
      AnalyticsService.logEvent('luno_payment_request_initiated', {
        'amount_btc': amountInBtc,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/luno/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amountInBtc': amountInBtc,
          'tierId': tierId,
          'email': email,
          'description': 'Meengle Premium Subscription',
          'metadata': {
            'tier_id': tierId,
            'product': 'premium_tier',
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('luno_payment_request_created', {
          'request_id': data['requestId'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('luno_payment_request_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get wallet balance
  static Future<Map<String, dynamic>?> getWalletBalance({
    required String walletId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/luno/wallet/$walletId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting wallet balance: $e');
      return null;
    }
  }

  /// Get transaction history
  static Future<List<Map<String, dynamic>>?> getTransactionHistory({
    required int limit,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/luno/transactions?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions']);
      }

      return null;
    } catch (e) {
      print('Error getting transaction history: $e');
      return null;
    }
  }

  /// Create recurring Bitcoin payment
  static Future<Map<String, dynamic>?> createRecurringPayment({
    required double amountInZar,
    required String tierId,
    required String frequency,
  }) async {
    try {
      AnalyticsService.logEvent('luno_recurring_payment_initiated', {
        'amount_zar': amountInZar,
        'frequency': frequency,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/luno/recurring'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amountInZar': amountInZar,
          'tierId': tierId,
          'frequency': frequency, // 'daily', 'weekly', 'monthly', 'yearly'
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('luno_recurring_created', {
          'agreement_id': data['agreementId'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('luno_recurring_error', {
        'error': e.toString(),
      });
      return null;
    }
  }
}
