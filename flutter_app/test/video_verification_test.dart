import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/video_verification_service.dart';

void main() {
  test('startVerification returns jobId', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/verify/video/start';
    final body = {'jobId': 'j_1', 'status': 'started'};
    fake.when(url, http.Response(jsonEncode(body), 200));

    final res = await VideoVerificationService.startVerification();
    expect(res['jobId'], equals('j_1'));
  });

  test('status returns status map', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/verify/video/j_1';
    final body = {'jobId': 'j_1', 'status': 'approved'};
    fake.when(url, http.Response(jsonEncode(body), 200));

    final res = await VideoVerificationService.status('j_1');
    expect(res['status'], equals('approved'));
  });
}
