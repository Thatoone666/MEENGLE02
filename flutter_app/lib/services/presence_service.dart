import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_profile.dart';

/// Service for tracking user presence and online status
class PresenceService {
  final String baseUrl;
  String? _authToken;

  PresenceService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Update user presence/status
  Future<bool> updatePresence({
    required String userId,
    required String status, // 'online', 'away', 'offline', 'on_call'
    bool isTyping = false,
    String? callWith,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/presence/update'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'status': status,
          'isTyping': isTyping,
          'callWith': callWith,
          'lastSeen': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[PresenceService] Presence updated: $status');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[PresenceService] Update error: $e');
      return false;
    }
  }

  /// Get user presence
  Future<UserPresence?> getUserPresence(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/presence/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserPresence(
          userId: data['userId'],
          status: data['status'] ?? 'offline',
          lastSeen: DateTime.parse(data['lastSeen']),
          isTyping: data['isTyping'] ?? false,
          currentCallWith: data['callWith'],
        );
      }
      return null;
    } catch (e) {
      debugPrint('[PresenceService] Get presence error: $e');
      return null;
    }
  }

  /// Set typing indicator
  Future<bool> setTypingIndicator(String chatId, String userId, bool isTyping) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/presence/typing'),
        headers: _headers,
        body: jsonEncode({
          'chatId': chatId,
          'userId': userId,
          'isTyping': isTyping,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[PresenceService] Typing indicator updated');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[PresenceService] Typing indicator error: $e');
      return false;
    }
  }

  /// Get multiple users' presence
  Future<List<UserPresence>> getMultiplePresence(List<String> userIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/presence/multiple'),
        headers: _headers,
        body: jsonEncode({'userIds': userIds}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final presences = (data['presences'] as List)
            .map((p) => UserPresence(
                  userId: p['userId'],
                  status: p['status'] ?? 'offline',
                  lastSeen: DateTime.parse(p['lastSeen']),
                  isTyping: p['isTyping'] ?? false,
                  currentCallWith: p['callWith'],
                ))
            .toList();
        return presences;
      }
      return [];
    } catch (e) {
      debugPrint('[PresenceService] Get multiple error: $e');
      return [];
    }
  }
}
