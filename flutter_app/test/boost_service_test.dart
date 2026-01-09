import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/boost_service.dart';

void main() {
  test('scheduleBoost returns boostId', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/boosts/schedule';
    fake.when(url, http.Response(jsonEncode({'boostId': 'b1'}), 200));
    final res = await BoostService.scheduleBoost(
        'u1', DateTime.now().toIso8601String(), 60, {'radius': 10});
    expect(res['boostId'], equals('b1'));
  });
}
