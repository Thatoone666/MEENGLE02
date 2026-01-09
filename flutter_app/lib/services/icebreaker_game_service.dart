import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for interactive icebreaker games
class IcebreakerGameService {
  final String baseUrl;
  String? _authToken;

  IcebreakerGameService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Get list of available games
  Future<List<Map<String, dynamic>>> getAvailableGames() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/available'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['games']);
      }
      return [];
    } catch (e) {
      debugPrint('[IcebreakerGameService] Get games error: $e');
      return [];
    }
  }

  /// Start a game with a match
  Future<Map<String, dynamic>?> startGame({
    required String userId,
    required String matchId,
    required String gameType, // 'would_you_rather', 'this_or_that', 'trivia', etc
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games/start'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'matchId': matchId,
          'gameType': gameType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[IcebreakerGameService] Game started: $gameType');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[IcebreakerGameService] Start game error: $e');
      return null;
    }
  }

  /// Submit game answer
  Future<bool> submitGameAnswer({
    required String gameId,
    required String userId,
    required String answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/answer'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'answer': answer,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[IcebreakerGameService] Answer submitted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[IcebreakerGameService] Submit answer error: $e');
      return false;
    }
  }

  /// Get game results
  Future<Map<String, dynamic>?> getGameResults(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId/results'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[IcebreakerGameService] Get results error: $e');
      return null;
    }
  }

  /// Get game history
  Future<List<Map<String, dynamic>>> getGameHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/history/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['history']);
      }
      return [];
    } catch (e) {
      debugPrint('[IcebreakerGameService] Get history error: $e');
      return [];
    }
  }

  /// Get game leaderboard
  Future<List<Map<String, dynamic>>> getGameLeaderboard({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/leaderboard?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['leaderboard']);
      }
      return [];
    } catch (e) {
      debugPrint('[IcebreakerGameService] Get leaderboard error: $e');
      return [];
    }
  }
}
