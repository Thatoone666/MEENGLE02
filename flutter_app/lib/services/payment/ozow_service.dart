import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../web/web_utils.dart';

class OzowService {
  static const String _apiUrl = String.fromEnvironment(
    'OZOW_API_URL',
    defaultValue: 'https://api.ozow.com',
  );

  final http.Client _client;
  final String _siteCode;
  final String _privateKey;

  OzowService({
    http.Client? client,
    String? siteCode,
    String? privateKey,
  })  : _client = client ?? http.Client(),
        _siteCode = siteCode ?? const String.fromEnvironment('OZOW_SITE_CODE'),
        _privateKey = privateKey ?? const String.fromEnvironment('OZOW_PRIVATE_KEY');

  Future<Map<String, String>> createPaymentRequest({
    required String amount,
    required String transactionReference,
    required String successUrl,
    required String cancelUrl,
    required String notifyUrl,
    required String bankReference,
    String? email,
  }) async {
    final data = {
      'SiteCode': _siteCode,
      'TransactionReference': transactionReference,
      'Amount': amount,
      'SuccessUrl': successUrl,
      'CancelUrl': cancelUrl,
      'NotifyUrl': notifyUrl,
      'BankReference': bankReference,
      'Customer': email ?? '',
    };

    // Create hash
    final hashString = [
      _siteCode,
      transactionReference,
      amount,
      successUrl,
      _privateKey,
    ].join('|');

    final hash = await compute(_calculateHash, hashString);
    
    return {
      ...data,
      'Hash': hash,
      'url': _apiUrl,
    };
  }

  Future<bool> verifyNotification(Map<String, String> data) async {
    try {
      final hash = data['Hash'];
      if (hash == null) return false;

      // Recreate hash from data
      final values = [
        data['SiteCode'],
        data['TransactionId'],
        data['Status'],
        data['Amount'],
        _privateKey,
      ];

      final hashString = values.join('|');
      final calculatedHash = await compute(_calculateHash, hashString);

      return calculatedHash.toLowerCase() == hash.toLowerCase();
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

String _calculateHash(String input) {
  // Implementation of hash calculation
  // This should be done in an isolate since it's CPU intensive
  return ''; // TODO: Implement actual hash calculation
}