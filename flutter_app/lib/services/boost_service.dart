import 'dart:convert';
import 'package:meengle_flutter/services/api.dart';

class BoostService {
  static Future<Map<String, dynamic>> scheduleBoost(String userId,
      String startIso, int durationMins, Map<String, dynamic> filters) async {
    final uri = Uri.parse('${ApiService.baseUrl}/api/boosts/schedule');
    final res = await ApiService.client.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'start': startIso,
          'duration': durationMins,
          'filters': filters
        }));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Schedule boost failed: ${res.statusCode}');
  }

  static Future<bool> boostNow() async {
    final url = Uri.parse('${ApiService.baseUrl}/api/profile/boost');
    final token = await ApiService.getToken();
    final res = await ApiService.client.post(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return res.statusCode == 200;
  }
}
