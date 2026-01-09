import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/ai_service.dart';

void main() {
  test('getIcebreakers returns prompts', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/ai/openers';
    fake.when(
        url,
        http.Response(
            jsonEncode({
              'prompts': ['hi', 'how are you?']
            }),
            200));
    final prompts = await AIService.getIcebreakers('u1', 'u2');
    expect(prompts.length, greaterThan(0));
  });
}
