import 'dart:convert';
import 'api.dart';

class AIProfileService {
  /// Get AI-powered bio suggestions.
  static Future<List<String>> getBioSuggestions(
      List<String> interests, String personality) async {
    final token = await ApiService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('${ApiService.baseUrl}/api/profile/ai-bio');
    final res = await ApiService.client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'interests': interests, 'personality': personality}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<String>.from(body['suggestions'] ?? []);
    }
    throw Exception('Failed to get bio suggestions: ${res.statusCode}');
  }

  /// Get AI analysis of user photos.
  static Future<Map<String, dynamic>> analyzePhotos(
      List<String> photoUrls) async {
    final token = await ApiService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri =
        Uri.parse('${ApiService.baseUrl}/api/profile/ai-photo-analysis');
    final res = await ApiService.client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'photoUrls': photoUrls}),
    );

    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to analyze photos: ${res.statusCode}');
  }
}
