import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for managing swipe history and rewinding
class SwipeHistoryService {
  final String baseUrl;
  String? _authToken;

  SwipeHistoryService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Record a swipe
  Future<bool> recordSwipe({
    required String userId,
    required String targetUserId,
    required String action, // 'like', 'pass', 'super_like'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/swipes/record'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'targetUserId': targetUserId,
          'action': action,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('[SwipeHistoryService] Swipe recorded: $action');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SwipeHistoryService] Record error: $e');
      return false;
    }
  }

  /// Get swipe history
  Future<List<Map<String, dynamic>>> getSwipeHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/swipes/history/$userId?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final history = List<Map<String, dynamic>>.from(data['swipes']);
        debugPrint('[SwipeHistoryService] Retrieved ${history.length} swipes');
        return history;
      }
      return [];
    } catch (e) {
      debugPrint('[SwipeHistoryService] Get history error: $e');
      return [];
    }
  }

  /// Undo last swipe (Rewind feature)
  Future<Map<String, dynamic>?> undoLastSwipe(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/swipes/undo'),
        headers: _headers,
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[SwipeHistoryService] Swipe undone');
        return data; // Returns the profile that was swiped on
      }
      return null;
    } catch (e) {
      debugPrint('[SwipeHistoryService] Undo error: $e');
      return null;
    }
  }

  /// Undo multiple swipes
  Future<List<Map<String, dynamic>>> undoMultipleSwipes(String userId, int count) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/swipes/undo-multiple'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'count': count.clamp(1, 5), // Max 5 undos
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profiles = List<Map<String, dynamic>>.from(data['profiles']);
        debugPrint('[SwipeHistoryService] $count swipes undone');
        return profiles;
      }
      return [];
    } catch (e) {
      debugPrint('[SwipeHistoryService] Undo multiple error: $e');
      return [];
    }
  }

  /// Get rewind availability (check if user has swipes left to undo)
  Future<Map<String, dynamic>?> getRewindInfo(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/swipes/rewind-info/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Contains rewind count, is_premium, etc
      }
      return null;
    } catch (e) {
      debugPrint('[SwipeHistoryService] Get rewind info error: $e');
      return null;
    }
  }
}
