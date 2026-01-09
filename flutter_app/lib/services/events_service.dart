import 'dart:convert';
import 'api.dart';

class EventsService {
  static Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> payload) async {
    final uri = Uri.parse('${ApiService.baseUrl}/api/events/create');
    final res = await ApiService.client.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Create event failed: ${res.statusCode}');
  }
}
