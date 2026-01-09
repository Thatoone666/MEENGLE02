import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'payment_provider.dart';

class OzowProvider implements PaymentProvider {
  static const String _sandboxUrl = 'https://api.ozow.com/test';
  static const String _productionUrl = 'https://api.ozow.com';

  final PaymentConfiguration _config;
  final http.Client _client;

  OzowProvider({
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
      throw PaymentException('Ozow only supports ZAR currency');
    }

    final transactionId = 'TR${DateTime.now().millisecondsSinceEpoch}';
    final data = {
      'SiteCode': _config.merchantId,
      'CountryCode': 'ZA',
      'CurrencyCode': 'ZAR',
      'Amount': amount,
      'TransactionReference': transactionId,
      'BankReference': description ?? 'Payment',
      'CustomerId': customerId,
      'SuccessUrl': _config.returnUrl,
      'ErrorUrl': _config.cancelUrl,
      'CancelUrl': _config.cancelUrl,
      'NotifyUrl': _config.notifyUrl,
      'IsTest': _config.isSandbox.toString(),
    };

    final hashString = _generateHash(data);
    data['HashCheck'] = hashString;

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/postpaymentrequest'),
        headers: {
          'Content-Type': 'application/json',
          'ApiKey': _config.merchantKey,
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'redirect_url': responseData['url'],
          'transaction_id': transactionId,
        };
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
    // Ozow doesn't support subscriptions directly
    throw PaymentException('Subscriptions not supported by Ozow');
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    // Ozow doesn't support subscriptions directly
    throw PaymentException('Subscriptions not supported by Ozow');
  }

  String _generateHash(Map<String, dynamic> data) {
    final values = [
      data['SiteCode'],
      data['CountryCode'],
      data['CurrencyCode'],
      data['Amount'],
      data['TransactionReference'],
      data['BankReference'],
      data['SuccessUrl'],
      data['ErrorUrl'],
      data['CancelUrl'],
      data['NotifyUrl'],
      data['IsTest'],
      _config.passphrase,
    ];

    final hashString = values.join('');
    return sha512.convert(utf8.encode(hashString)).toString();
  }

  void dispose() {
    _client.close();
  }
}