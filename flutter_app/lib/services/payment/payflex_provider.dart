import 'package:http/http.dart' as http;
import 'dart:convert';
import '../analytics_service.dart';

/// PayFlex payment provider - Buy now pay later (BNPL) solution
/// PayFlex offers flexible payment plans with installments
class PayFlexPaymentProvider {
  static const String _apiKey = 'api_key_meengle_payflex'; // Replace with actual key
  static const String _backendUrl = 'http://localhost:3000/api';
  static const String _payflexApiUrl = 'https://api.payflex.co.za';

  /// Create PayFlex payment plan
  static Future<Map<String, dynamic>?> createPaymentPlan({
    required double amount,
    required String tierId,
    required String email,
    required String phoneNumber,
    required int numberOfInstallments,
  }) async {
    try {
      AnalyticsService.logEvent('payflex_plan_initiated', {
        'amount': amount,
        'tier_id': tierId,
        'installments': numberOfInstallments,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/payflex/plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'phoneNumber': phoneNumber,
          'numberOfInstallments': numberOfInstallments,
          'description': 'Meengle Premium Subscription',
          'redirectUrl': 'https://meengle.app/payment-success',
          'metadata': {
            'tier_id': tierId,
            'product': 'premium_tier',
            'user_email': email,
            'installments': numberOfInstallments,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('payflex_plan_created', {
          'plan_id': data['planId'],
          'installments': numberOfInstallments,
          'amount_per_installment': data['amountPerInstallment'],
        });
        return data;
      }

      AnalyticsService.logEvent('payflex_plan_failed', {
        'error': response.body,
      });
      return null;
    } catch (e) {
      AnalyticsService.logEvent('payflex_plan_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get available installment plans
  static Future<List<Map<String, dynamic>>?> getAvailablePlans({
    required double amount,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/payflex/plans?amount=$amount'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['plans']);
      }

      return null;
    } catch (e) {
      print('Error getting PayFlex plans: $e');
      return null;
    }
  }

  /// Get plan details
  static Future<Map<String, dynamic>?> getPlanDetails({
    required String planId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/payflex/plan/$planId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting PayFlex plan details: $e');
      return null;
    }
  }

  /// Get payment schedule
  static Future<List<Map<String, dynamic>>?> getPaymentSchedule({
    required String planId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/payflex/plan/$planId/schedule'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['schedule']);
      }

      return null;
    } catch (e) {
      print('Error getting PayFlex payment schedule: $e');
      return null;
    }
  }

  /// Cancel payment plan
  static Future<bool> cancelPlan({
    required String planId,
  }) async {
    try {
      AnalyticsService.logEvent('payflex_plan_cancellation_initiated', {
        'plan_id': planId,
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/payments/payflex/plan/$planId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': 'user_request'}),
      );

      if (response.statusCode == 200) {
        AnalyticsService.logEvent('payflex_plan_cancelled', {
          'plan_id': planId,
        });
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('payflex_plan_cancellation_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Update payment plan
  static Future<Map<String, dynamic>?> updatePlan({
    required String planId,
    required int newNumberOfInstallments,
  }) async {
    try {
      AnalyticsService.logEvent('payflex_plan_update_initiated', {
        'plan_id': planId,
        'new_installments': newNumberOfInstallments,
      });

      final response = await http.patch(
        Uri.parse('$_backendUrl/payments/payflex/plan/$planId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numberOfInstallments': newNumberOfInstallments,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('payflex_plan_updated', {
          'plan_id': planId,
          'new_installments': newNumberOfInstallments,
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('payflex_plan_update_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Get transaction history
  static Future<List<Map<String, dynamic>>?> getTransactionHistory({
    required String email,
    required int limit,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/payments/payflex/history?email=$email&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions']);
      }

      return null;
    } catch (e) {
      print('Error getting PayFlex transaction history: $e');
      return null;
    }
  }
}
