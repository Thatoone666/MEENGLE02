import 'package:http/http.dart' as http;
import 'dart:convert';
import '../analytics_service.dart';

/// PayShap payment provider - Buy now pay later (BNPL) for South Africa
/// PayShap enables payment plans with zero interest
class PayShapPaymentProvider {
  static const String _apiKey = 'api_key_meengle_payshap'; // Replace with actual key
  static const String _backendUrl = 'http://localhost:3000/api';
  static const String _payshapApiUrl = 'https://api.payshap.co.za';

  /// Create PayShap payment plan
  static Future<Map<String, dynamic>?> createPaymentPlan({
    required double amount,
    required String tierId,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      AnalyticsService.logEvent('payshap_plan_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/payshap/plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'phoneNumber': phoneNumber,
          'description': 'Meengle Premium Subscription',
          'numberOfInstallments': 3, // 3 payments default
          'metadata': {
            'tier_id': tierId,
            'product': 'premium_tier',
            'user_email': email,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('payshap_plan_created', {
          'plan_id': data['planId'],
          'installments': data['numberOfInstallments'],
          'amount_per_installment': data['amountPerInstallment'],
        });
        return data;
      }

      AnalyticsService.logEvent('payshap_plan_failed', {
        'error': response.body,
      });
      return null;
    } catch (e) {
      AnalyticsService.logEvent('payshap_plan_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get available payment plans
  static Future<List<Map<String, dynamic>>?> getAvailablePlans({
    required double amount,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/payshap/plans?amount=$amount'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['plans']);
      }

      return null;
    } catch (e) {
      print('Error getting PayShap plans: $e');
      return null;
    }
  }

  /// Check plan status
  static Future<Map<String, dynamic>?> getPlanStatus({
    required String planId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/payshap/plan/$planId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting PayShap plan status: $e');
      return null;
    }
  }

  /// Cancel payment plan
  static Future<bool> cancelPlan({
    required String planId,
  }) async {
    try {
      AnalyticsService.logEvent('payshap_plan_cancellation_initiated', {
        'plan_id': planId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/payshap/plan/$planId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': 'user_request'}),
      );

      if (response.statusCode == 200) {
        AnalyticsService.logEvent('payshap_plan_cancelled', {
          'plan_id': planId,
        });
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('payshap_plan_cancellation_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get payment history for plan
  static Future<List<Map<String, dynamic>>?> getPlanPaymentHistory({
    required String planId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/payshap/plan/$planId/history'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['payments']);
      }

      return null;
    } catch (e) {
      print('Error getting PayShap payment history: $e');
      return null;
    }
  }
}
