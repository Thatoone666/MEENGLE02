import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/events_service.dart';

void main() {
  test('createEvent returns eventId', () async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/events/create';
    fake.when(url, http.Response(jsonEncode({'eventId': 'e1'}), 200));
    final res = await EventsService.createEvent({'title': 'Test'});
    expect(res['eventId'], equals('e1'));
  });
}
