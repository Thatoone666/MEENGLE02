import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_profile.dart';

/// Service for advanced matching and compatibility
class MatchingService {
  final String baseUrl;
  String? _authToken;

  MatchingService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Get compatibility score with explanation
  Future<MatchCompatibility?> getMatchCompatibility(
    String userId,
    String targetUserId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matching/compatibility/$userId/$targetUserId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final compatibility = MatchCompatibility(
          userId: targetUserId,
          compatibilityScore: data['score'] ?? 0,
          commonInterests: List<String>.from(data['commonInterests'] ?? []),
          commonVerifications: List<String>.from(data['commonVerifications'] ?? []),
          reason: data['reason'] ?? 'Good match!',
        );
        debugPrint('[MatchingService] Compatibility: ${compatibility.compatibilityScore}%');
        return compatibility;
      }
      return null;
    } catch (e) {
      debugPrint('[MatchingService] Get compatibility error: $e');
      return null;
    }
  }

  /// Calculate compatibility locally (if backend unavailable)
  int calculateLocalCompatibility(Map<String, dynamic> user1, Map<String, dynamic> user2) {
    int score = 50; // Base score

    // Common interests
    final interests1 = List<String>.from(user1['interests'] ?? []);
    final interests2 = List<String>.from(user2['interests'] ?? []);
    final commonInterests = interests1.toSet().intersection(interests2.toSet());
    score += (commonInterests.length * 5).clamp(0, 20);

    // Age compatibility
    final age1 = user1['age'] ?? 25;
    final age2 = user2['age'] ?? 25;
    final ageDiff = (age1 - age2).abs();
    if (ageDiff <= 5) score += 10;
    if (ageDiff <= 10) score += 5;

    // Location proximity
    final distKm = user1['distance'] ?? 50;
    if (distKm < 5) score += 15;
    if (distKm < 15) score += 10;
    if (distKm < 50) score += 5;

    // Verification match
    final verif1 = List<String>.from(user1['verifications'] ?? []);
    final verif2 = List<String>.from(user2['verifications'] ?? []);
    if (verif1.isNotEmpty && verif2.isNotEmpty) score += 10;

    return score.clamp(0, 100);
  }

  /// Get list of highly compatible matches
  Future<List<MatchCompatibility>> getTopMatches(String userId, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matching/top-matches/$userId?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final matches = (data['matches'] as List)
            .map((m) => MatchCompatibility(
                  userId: m['userId'],
                  compatibilityScore: m['score'] ?? 0,
                  commonInterests: List<String>.from(m['commonInterests'] ?? []),
                  commonVerifications: List<String>.from(m['commonVerifications'] ?? []),
                  reason: m['reason'] ?? 'Great match!',
                ))
            .toList();
        debugPrint('[MatchingService] Retrieved ${matches.length} top matches');
        return matches;
      }
      return [];
    } catch (e) {
      debugPrint('[MatchingService] Get top matches error: $e');
      return [];
    }
  }
}
