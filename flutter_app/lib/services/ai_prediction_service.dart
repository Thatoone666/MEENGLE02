import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI-Powered personalization and match prediction service
class AIPredictionService {
  static const String _baseUrl = 'http://localhost:5000/api/ai';
  static const String _modelVersion = 'v1.0';

  /// User behavior profile for ML model
  static Future<Map<String, dynamic>> getUserBehaviorProfile(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching behavior profile: $e');
      return {};
    }
  }

  /// Predict match compatibility using ML model
  static Future<double> predictMatchCompatibility(
    String userId,
    String targetUserId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict-compatibility'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'targetUserId': targetUserId,
          'modelVersion': _modelVersion,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['compatibility'] as num).toDouble();
      } else {
        return 0.5; // Default middle value
      }
    } catch (e) {
      print('Error predicting compatibility: $e');
      return 0.5;
    }
  }

  /// Get personalized suggestions based on user behavior
  static Future<List<Map<String, dynamic>>> getPersonalizedSuggestions(
    String userId,
    int limit = 10,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/suggestions/$userId?limit=$limit'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['suggestions'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  /// Analyze user preferences from interactions
  static Future<Map<String, dynamic>> analyzePreferences(
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-preferences'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error analyzing preferences: $e');
      return {};
    }
  }

  /// Get predictive animations based on user interaction patterns
  static Future<Map<String, dynamic>> getPredictiveAnimations(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/animation-preferences/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching animation preferences: $e');
      return {};
    }
  }

  /// Track user interaction for model training
  static Future<void> trackInteraction(
    String userId,
    String targetUserId,
    String interactionType,
    Map<String, dynamic> metadata,
  ) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/track-interaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'targetUserId': targetUserId,
          'interactionType': interactionType,
          'metadata': metadata,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error tracking interaction: $e');
    }
  }

  /// Get behavioral insights
  static Future<Map<String, dynamic>> getBehavioralInsights(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/insights/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching insights: $e');
      return {};
    }
  }
}
