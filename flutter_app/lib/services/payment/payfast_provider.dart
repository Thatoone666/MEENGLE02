import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'payment_provider.dart';

class PayFastProvider implements PaymentProvider {
  static const String _sandboxUrl = 'https://sandbox.payfast.co.za';
  static const String _productionUrl = 'https://www.payfast.co.za';

  final PaymentConfiguration _config;
  final http.Client _client;

  PayFastProvider({
    required PaymentConfiguration config,
    http.Client? client,
  })  : _config = config,
        _client = client ?? http.Client();

  String get _baseUrl => _config.isSandbox ? _sandboxUrl : _productionUrl;

  @override
  Future<Map<String, dynamic>> createPayment({
    required String amount,
    required String currency,
    required String customerId,
    String? description,
  }) async {
    if (currency.toUpperCase() != 'ZAR') {
      throw PaymentException('PayFast only supports ZAR currency');
    }

    final data = {
      'merchant_id': _config.merchantId,
      'merchant_key': _config.merchantKey,
      'return_url': _config.returnUrl,
      'cancel_url': _config.cancelUrl,
      'notify_url': _config.notifyUrl,
      'amount': amount,
      'item_name': description ?? 'Payment',
      'custom_str1': customerId,
    };

    data['signature'] = _generateSignature(data);

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/eng/process'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      if (response.statusCode == 200) {
        return {'redirect_url': response.request?.url.toString()};
      } else {
        throw PaymentException(
          'Payment creation failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      throw PaymentException('Payment creation failed', e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String planId,
  }) async {
    // PayFast subscription setup
    final data = {
      'merchant_id': _config.merchantId,
      'merchant_key': _config.merchantKey,
      'return_url': _config.returnUrl,
      'cancel_url': _config.cancelUrl,
      'notify_url': _config.notifyUrl,
      'subscription_type': '1', // Recurring billing
      'billing_date': DateTime.now().toIso8601String(),
      'custom_str1': customerId,
      'item_name': 'Subscription: $planId',
      'frequency': '3', // Monthly
      'cycles': '0', // Unlimited
    };

    data['signature'] = _generateSignature(data);

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/eng/recurring/subscribe'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      if (response.statusCode == 200) {
        return {'redirect_url': response.request?.url.toString()};
      } else {
        throw PaymentException(
          'Subscription creation failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      throw PaymentException('Subscription creation failed', e.toString());
    }
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    final data = {
      'merchant_id': _config.merchantId,
      'version': 'v1',
      'timestamp': DateTime.now().toIso8601String(),
      'subscription_id': subscriptionId,
    };

    data['signature'] = _generateSignature(data);

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/eng/recurring/cancel'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      if (response.statusCode != 200) {
        throw PaymentException(
          'Subscription cancellation failed: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      throw PaymentException('Subscription cancellation failed', e.toString());
    }
  }

  String _generateSignature(Map<String, dynamic> data) {
    final sortedKeys = data.keys.toList()..sort();
    final signatureString = sortedKeys
        .map((key) => '$key=${Uri.encodeComponent(data[key].toString())}')
        .join('&');
    
    final signature = md5
        .convert(utf8.encode(signatureString + _config.passphrase))
        .toString();
    
    return signature;
  }

  void dispose() {
    _client.close();
  }
}

class PaymentException implements Exception {
  final String message;
  final String details;

  PaymentException(this.message, [this.details = '']);

  @override
  String toString() => 'PaymentException: $message${details.isNotEmpty ? '\nDetails: $details' : ''}';
}