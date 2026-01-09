import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';

void main() {
  test('createPayFast returns parsed map on 200', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/payfast';
    final body = {
      'redirect': 'https://payfast.example/checkout',
      'token': 'pf_123'
    };
    fake.when(url, http.Response(jsonEncode(body), 200));

    final res = await ApiService.createPayFast('9.99', 'Test Item', 'a@b.com');
    expect(res['redirect'], equals('https://payfast.example/checkout'));
    expect(res['token'], equals('pf_123'));
  });

  test('createPayPal returns parsed map on 200', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/paypal';
    final body = {
      'approval_url': 'https://paypal.example/approve',
      'id': 'pp_456'
    };
    fake.when(url, http.Response(jsonEncode(body), 200));

    final res = await ApiService.createPayPal('4.99', 'Item');
    expect(res['approval_url'], equals('https://paypal.example/approve'));
    expect(res['id'], equals('pp_456'));
  });
}
