import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_profile.dart';

/// Service for managing achievement badges
class AchievementService {
  final String baseUrl;
  String? _authToken;

  AchievementService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Get user's achievements
  Future<List<AchievementBadge>> getUserAchievements(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/achievements/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final badges = (data['badges'] as List)
            .map((b) => AchievementBadge(
                  id: b['id'],
                  name: b['name'],
                  description: b['description'],
                  icon: b['icon'],
                  unlockedAt: DateTime.parse(b['unlockedAt']),
                  category: b['category'],
                ))
            .toList();
        debugPrint('[AchievementService] Retrieved ${badges.length} achievements');
        return badges;
      }
      return [];
    } catch (e) {
      debugPrint('[AchievementService] Get achievements error: $e');
      return [];
    }
  }

  /// Award achievement
  Future<bool> awardAchievement(String userId, String achievementId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/achievements/$userId/award'),
        headers: _headers,
        body: jsonEncode({'achievementId': achievementId}),
      );

      if (response.statusCode == 200) {
        debugPrint('[AchievementService] Achievement awarded');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AchievementService] Award error: $e');
      return false;
    }
  }

  /// Check if user has achievement
  Future<bool> hasAchievement(String userId, String achievementId) async {
    try {
      final achievements = await getUserAchievements(userId);
      return achievements.any((a) => a.id == achievementId);
    } catch (e) {
      debugPrint('[AchievementService] Check achievement error: $e');
      return false;
    }
  }

  /// Get all possible achievements (unlocked or not)
  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/achievements/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['achievements']);
      }
      return [];
    } catch (e) {
      debugPrint('[AchievementService] Get all error: $e');
      return [];
    }
  }

  IconData getAchievementIcon(String category) {
    switch (category.toLowerCase()) {
      case 'verification':
        return Icons.verified;
      case 'activity':
        return Icons.star;
      case 'milestone':
        return Icons.flag;
      default:
        return Icons.check;
    }
  }
}
