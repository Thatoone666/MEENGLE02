import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/voice_service.dart';

void main() {
  test('uploadVoice returns url map', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/upload';
    fake.when(
        url,
        http.Response(
            jsonEncode({'url': 'https://cdn.example/voice.mp3'}), 200));
    final res = await VoiceService.uploadVoice('path/to/file.mp3', 'file.mp3');
    expect(res['url'], isNotNull);
  });
}
