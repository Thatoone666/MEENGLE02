import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../web/web_utils.dart';

class StripeService {
  static const String _apiUrl = String.fromEnvironment('STRIPE_API_URL', 
    defaultValue: 'https://api.stripe.com/v1');
  
  static const String _publishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_your_key');

  final String _secretKey;
  final http.Client _client;

  StripeService({String? secretKey, http.Client? client})
      : _secretKey = secretKey ?? const String.fromEnvironment('STRIPE_SECRET_KEY'),
        _client = client ?? http.Client();

  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String customerId,
    String? description,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl/payment_intents'),
        headers: _getHeaders(),
        body: {
          'amount': amount,
          'currency': currency,
          'customer': customerId,
          if (description != null) 'description': description,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw PaymentException(
          'Failed to create payment intent: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      throw PaymentException('Payment intent creation failed', e.toString());
    }
  }

  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String priceId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl/subscriptions'),
        headers: _getHeaders(),
        body: {
          'customer': customerId,
          'items[0][price]': priceId,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw PaymentException(
          'Failed to create subscription: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      throw PaymentException('Subscription creation failed', e.toString());
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required String email,
    String? name,
    Map<String, String>? metadata,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'email': email,
        if (name != null) 'name': name,
        if (metadata != null)
          for (var entry in metadata.entries) 'metadata[${entry.key}]': entry.value,
      };

      final response = await _client.post(
        Uri.parse('$_apiUrl/customers'),
        headers: _getHeaders(),
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw PaymentException(
          'Failed to create customer: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      throw PaymentException('Customer creation failed', e.toString());
    }
  }

  Future<Map<String, dynamic>> attachPaymentMethod({
    required String paymentMethodId,
    required String customerId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl/payment_methods/$paymentMethodId/attach'),
        headers: _getHeaders(),
        body: {'customer': customerId},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw PaymentException(
          'Failed to attach payment method: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      throw PaymentException('Payment method attachment failed', e.toString());
    }
  }

  Map<String, String> _getHeaders() => {
    'Authorization': 'Bearer $_secretKey',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  void dispose() {
    _client.close();
  }

  static String get publishableKey => _publishableKey;
}

class PaymentException implements Exception {
  final String message;
  final String details;

  PaymentException(this.message, [this.details = '']);

  @override
  String toString() => 'PaymentException: $message${details.isNotEmpty ? '\nDetails: $details' : ''}';
}