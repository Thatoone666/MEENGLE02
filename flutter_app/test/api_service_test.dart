import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/api.dart';

void main() {
  test('ApiService.createStripePayment parses clientSecret', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/stripe';
    fake.when(
        url,
        http.Response(jsonEncode({'clientSecret': 'cs_test_123'}), 200,
            headers: {'content-type': 'application/json'}));

    final res =
        await ApiService.createStripePayment('9.99', 'Premium', 'a@b.com');
    expect(res['clientSecret'], 'cs_test_123');
  });
}

// test uses real http.Response via FakeApiClient.when
