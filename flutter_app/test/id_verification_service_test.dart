import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/id_verification_service.dart';

void main() {
  test('startIdVerification returns job', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/verify/id/start';
    fake.when(url, http.Response(jsonEncode({'jobId': 'jid1'}), 200));
    final res = await IdVerificationService.startIdVerification();
    expect(res['jobId'], equals('jid1'));
  });
}
