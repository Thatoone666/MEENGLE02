import 'package:http/http.dart' as http;
import 'dart:convert';
import '../analytics_service.dart';

/// SnapScan payment provider - Instant bank transfer via QR code
/// SnapScan allows quick payments via scanning QR codes with bank apps
class SnapScanPaymentProvider {
  static const String _apiKey = 'api_key_meengle_snapscan'; // Replace with actual key
  static const String _backendUrl = 'http://localhost:3000/api';
  static const String _snapScanApiUrl = 'https://snapscan.io/api';

  /// Create SnapScan QR code for payment
  static Future<Map<String, dynamic>?> createQRPayment({
    required double amount,
    required String tierId,
    required String phoneNumber,
  }) async {
    try {
      AnalyticsService.logEvent('snapscan_qr_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/snapscan/qr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'phoneNumber': phoneNumber,
          'description': 'Meengle Premium Subscription',
          'metadata': {
            'tier_id': tierId,
            'product': 'premium_tier',
            'phone': phoneNumber,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('snapscan_qr_created', {
          'transaction_id': data['transactionId'],
          'qr_code': data['qrCode'],
        });
        return data;
      }

      AnalyticsService.logEvent('snapscan_qr_failed', {
        'error': response.body,
      });
      return null;
    } catch (e) {
      AnalyticsService.logEvent('snapscan_qr_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create SnapCode (SnapScan's unique identifier)
  static Future<Map<String, dynamic>?> createSnapCode({
    required double amount,
    required String tierId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/payments/snapscan/code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error creating SnapScan code: $e');
      return null;
    }
  }

  /// Check transaction status
  static Future<Map<String, dynamic>?> getTransactionStatus({
    required String transactionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/snapscan/status/$transactionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting SnapScan transaction status: $e');
      return null;
    }
  }

  /// Get merchant details
  static Future<Map<String, dynamic>?> getMerchantDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/snapscan/merchant'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting SnapScan merchant details: $e');
      return null;
    }
  }

  /// Request refund for transaction
  static Future<bool> requestRefund({
    required String transactionId,
    required String reason,
  }) async {
    try {
      AnalyticsService.logEvent('snapscan_refund_requested', {
        'transaction_id': transactionId,
        'reason': reason,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/snapscan/refund'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'transactionId': transactionId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        AnalyticsService.logEvent('snapscan_refund_processed', {
          'transaction_id': transactionId,
        });
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('snapscan_refund_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get webhook events
  static Future<List<Map<String, dynamic>>?> getWebhookEvents({
    required String eventType,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/snapscan/webhooks?type=$eventType'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['events']);
      }

      return null;
    } catch (e) {
      print('Error getting SnapScan webhook events: $e');
      return null;
    }
  }
}
