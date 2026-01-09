import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';

void main() {
  test('uploadVideo returns true on successful upload', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/upload';
    final body = {'url': 'https://cdn.example/test.mp4'};
    // Fake multipart implementation stores response keyed by URL (sendMultipart uses req.url)
    fake.when(url, http.Response(jsonEncode(body), 200));

    final ok =
        await ApiService.uploadFile('test_assets/sample.mp4', 'sample.mp4');
    expect(ok, isNotNull);
  });
}
