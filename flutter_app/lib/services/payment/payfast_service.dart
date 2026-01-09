import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../web/web_utils.dart';

class PayFastService {
  static const String _apiUrl = String.fromEnvironment(
    'PAYFAST_API_URL',
    defaultValue: 'https://sandbox.payfast.co.za/eng/process',
  );

  final http.Client _client;
  final String _merchantId;
  final String _merchantKey;

  PayFastService({
    http.Client? client,
    String? merchantId,
    String? merchantKey,
  })  : _client = client ?? http.Client(),
        _merchantId = merchantId ?? const String.fromEnvironment('PAYFAST_MERCHANT_ID'),
        _merchantKey = merchantKey ?? const String.fromEnvironment('PAYFAST_MERCHANT_KEY');

  Future<Map<String, String>> createPaymentRequest({
    required String amount,
    required String itemName,
    required String returnUrl,
    required String cancelUrl,
    required String notifyUrl,
    String? email,
    String? firstName,
    String? lastName,
    Map<String, String>? customFields,
  }) async {
    final data = {
      'merchant_id': _merchantId,
      'merchant_key': _merchantKey,
      'return_url': returnUrl,
      'cancel_url': cancelUrl,
      'notify_url': notifyUrl,
      'name_first': firstName ?? '',
      'name_last': lastName ?? '',
      'email_address': email ?? '',
      'amount': amount,
      'item_name': itemName,
      ...?customFields,
    };

    // Sort alphabetically for signature
    final sortedKeys = data.keys.toList()..sort();
    final signatureString = sortedKeys
        .map((key) => '$key=${Uri.encodeComponent(data[key]!)}')
        .join('&');

    // Calculate signature
    final bytes = utf8.encode(signatureString);
    final signature = await compute(_calculateMd5, bytes);
    
    return {
      ...data,
      'signature': signature,
      'url': _apiUrl,
    };
  }

  Future<bool> verifyNotification(Map<String, String> data, String signature) async {
    try {
      // Sort the data alphabetically
      final sortedKeys = data.keys.toList()..sort();
      final signatureString = sortedKeys
          .where((key) => key != 'signature')
          .map((key) => '$key=${Uri.encodeComponent(data[key]!)}')
          .join('&');

      // Calculate MD5 hash
      final bytes = utf8.encode(signatureString);
      final digest = await compute(_calculateMd5, bytes);

      return digest.toLowerCase() == signature.toLowerCase();
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      return false;
    }
  }

  Future<Map<String, dynamic>> getClientIp() async {
    try {
      final response = await _client.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'ip': 'unknown'};
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      return {'ip': 'unknown'};
    }
  }

  void dispose() {
    _client.close();
  }
}

String _calculateMd5(List<int> bytes) {
  // Implementation of MD5 hash calculation
  // This should be done in an isolate since it's CPU intensive
  return ''; // TODO: Implement atual MD5 calculation
}