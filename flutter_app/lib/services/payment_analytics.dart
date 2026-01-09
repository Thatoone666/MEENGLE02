import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../web/web_utils.dart';

class PaymentAnalytics {
  static const String _analyticsUrl = String.fromEnvironment(
    'ANALYTICS_API_URL',
    defaultValue: 'https://api.meengle.com/analytics',
  );

  final http.Client _client;

  PaymentAnalytics({http.Client? client}) : _client = client ?? http.Client();

  Future<void> trackPaymentEvent({
    required String eventName,
    required String userId,
    required String paymentMethod,
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = {
        'event': eventName,
        'userId': userId,
        'paymentMethod': paymentMethod,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
        if (metadata != null) ...metadata,
      };

      final response = await _client.post(
        Uri.parse('$_analyticsUrl/payment-events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to track payment event: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      debugPrint('Failed to track payment event: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentMetrics({
    required String userId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = {
        'userId': userId,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };

      final response = await _client.get(
        Uri.parse('$_analyticsUrl/payment-metrics').replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get payment metrics: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}