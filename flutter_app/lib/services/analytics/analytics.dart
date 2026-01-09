import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../web/web_utils.dart';

class Analytics {
  static const String _apiUrl = String.fromEnvironment(
    'ANALYTICS_API_URL',
    defaultValue: 'https://api.meengle.com/analytics',
  );

  final http.Client _client;

  Analytics({http.Client? client}) : _client = client ?? http.Client();

  Future<void> logPaymentSuccess({
    required String transactionId,
    required String method,
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      'payment_success',
      {
        'transactionId': transactionId,
        'method': method,
        'amount': amount,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<void> logPaymentFailure({
    required String transactionId,
    required String method,
    required String error,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      'payment_failure',
      {
        'transactionId': transactionId,
        'method': method,
        'error': error,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<void> logSubscriptionCreated({
    required String subscriptionId,
    required String tier,
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      'subscription_created',
      {
        'subscriptionId': subscriptionId,
        'tier': tier,
        'amount': amount,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<void> logSubscriptionCancelled({
    required String subscriptionId,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      'subscription_cancelled',
      {
        'subscriptionId': subscriptionId,
        'reason': reason,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<void> logSubscriptionError({
    required String error,
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      'subscription_error',
      {
        'error': error,
        if (transactionId != null) 'transactionId': transactionId,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<void> logBlockedTransaction({
    required String transactionId,
    required dynamic riskAssessment,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      'transaction_blocked',
      {
        'transactionId': transactionId,
        'risk_assessment': riskAssessment,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<void> logSuspiciousTransaction({
    required String transactionId,
    required dynamic riskAssessment,
    Map<String, dynamic>? metadata,
  }) async {
    await _logEvent(
      'transaction_suspicious',
      {
        'transactionId': transactionId,
        'risk_assessment': riskAssessment,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<void> _logEvent(String eventName, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl/events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'event': eventName,
          'timestamp': DateTime.now().toIso8601String(),
          'platform': kIsWeb ? 'web' : 'mobile',
          'data': data,
        }),
      );

      if (response.statusCode != 200) {
        if (kIsWeb) {
          WebUtils.handleWebError(
            'Failed to log event: ${response.statusCode}',
            StackTrace.current,
          );
        }
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
    }
  }

  void dispose() {
    _client.close();
  }
}