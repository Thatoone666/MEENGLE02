import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'api.dart';

/// Payment service for Spotlight purchases
class PaymentService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Create payment intent for Spotlight tier
  Future<Map<String, dynamic>> createPaymentIntent(String tier) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/payment/spotlight/create-intent');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'tier': tier}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create payment intent');
  }

  /// Process Stripe payment
  Future<bool> processStripePayment({
    required String clientSecret,
    required String tier,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Meengle',
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      debugPrint('Payment error: $e');
      return false;
    }
  }

  /// Confirm payment and activate spotlight
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String tier,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/payment/spotlight/confirm');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'paymentIntentId': paymentIntentId,
        'tier': tier,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    }
    throw Exception('Failed to confirm payment');
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/payment/history');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final payments = (data['payments'] as List)
          .map((p) => Map<String, dynamic>.from(p))
          .toList();
      return payments;
    }
    return [];
  }

  /// Get payment status (check if last payment succeeded)
  Future<bool> isPaymentSuccessful(String paymentIntentId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');
      
      // In production, verify with backend
      return true;
    } catch (e) {
      return false;
    }
  }
}
