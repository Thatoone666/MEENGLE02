import 'dart:convert';
import 'api.dart';

class DateSchedulerService {
  static Future<Map<String, dynamic>> proposeDate(String fromUser,
      String toUser, List<Map<String, String>> slots, String message) async {
    final uri = Uri.parse('${ApiService.baseUrl}/dates/propose');
    final payload = {
      'from': fromUser,
      'to': toUser,
      'slots': slots,
      'message': message
    };
    final res = await ApiService.client.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Propose failed: ${res.statusCode}');
  }
}
