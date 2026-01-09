import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../web/web_utils.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.meengle.com/api',
  );

  final http.Client _client;

  SubscriptionService({http.Client? client})
      : _client = client ?? http.Client();

  Future<Subscription> getCurrentSubscription(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_apiUrl/subscriptions/current/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Subscription.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get subscription: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<Subscription> createSubscription({
    required String userId,
    required SubscriptionTier tier,
    required String paymentMethod,
    required double amount,
    required String transactionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl/subscriptions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'tier': tier.name,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'transactionId': transactionId,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        return Subscription.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl/subscriptions/$subscriptionId/cancel'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<List<Subscription>> getSubscriptionHistory(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_apiUrl/subscriptions/history/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Subscription.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get subscription history: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUsageMetrics(String subscriptionId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_apiUrl/subscriptions/$subscriptionId/metrics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get usage metrics: ${response.statusCode}');
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