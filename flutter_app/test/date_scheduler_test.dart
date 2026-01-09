import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/date_scheduler_service.dart';

void main() {
  test('proposeDate posts and returns response', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/dates/propose';
    final body = {'dateId': 'd_1', 'status': 'pending'};
    fake.when(url, http.Response(jsonEncode(body), 200));

    final res = await DateSchedulerService.proposeDate(
        'u1',
        'u2',
        [
          {'start': '2025-09-26T19:00:00Z', 'end': '2025-09-26T20:00:00Z'}
        ],
        'Wanna meet?');
    expect(res['dateId'], equals('d_1'));
  });
}
