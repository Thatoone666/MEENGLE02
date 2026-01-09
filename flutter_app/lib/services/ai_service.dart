import 'dart:convert';
import 'api.dart';

class AIService {
  /// Get icebreaker suggestions for a match/context
  static Future<List<String>> getIcebreakers(String userId, String matchId,
      {String? context}) async {
    final uri = Uri.parse('${ApiService.baseUrl}/api/ai/openers');
    final res = await ApiService.client.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'userId': userId, 'matchId': matchId, 'context': context}));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is Map && body['prompts'] is List) {
        return List<String>.from(body['prompts']);
      }
      return [];
    }
    throw Exception('AI openers failed: ${res.statusCode}');
  }
}
