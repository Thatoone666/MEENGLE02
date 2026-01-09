import 'dart:convert';
import 'api.dart';

class IdVerificationService {
  static Future<Map<String, dynamic>> startIdVerification() async {
    final uri = Uri.parse('${ApiService.baseUrl}/api/verify/id/start');
    final res = await ApiService.client
        .post(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('ID verification start failed: ${res.statusCode}');
  }
}
