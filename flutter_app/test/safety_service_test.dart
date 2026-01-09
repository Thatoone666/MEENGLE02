import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/safety_service.dart';

void main() {
  test('shareEta returns shareUrl', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/safety/eta';
    fake.when(url,
        http.Response(jsonEncode({'shareUrl': 'https://share/eta/1'}), 200));
    final res = await SafetyService.shareEta(
        'u1', 'u2', DateTime.now().toIso8601String());
    expect(res['shareUrl'], isNotNull);
  });
}
