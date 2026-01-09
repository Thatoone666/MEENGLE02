import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/premium_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('purchaseSubscriptionViaStripe forwards response', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/stripe';
    final body = {'clientSecret': 'cs_test_123'};
    fake.when(url, http.Response(jsonEncode(body), 200));

    final resp = await PremiumService.purchaseSubscriptionViaStripe(
        '9.99', 'alice@example.com');
    expect(resp['clientSecret'], equals('cs_test_123'));
  });

  test('setPremium and isPremium work via SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await PremiumService.isPremium(), isFalse);
    await PremiumService.setPremium(true);
    expect(await PremiumService.isPremium(), isTrue);
  });
}
