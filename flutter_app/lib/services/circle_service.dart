import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meengle_flutter/models/meengle_circle.dart';
import 'api.dart';

/// Service for managing Meengle Circles
class CircleService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Get all circles
  Future<List<MeengleCircle>> getAllCircles() async {
    final token = await _getToken();
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/discover');
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final circles = (data['circles'] as List)
          .map((c) => MeengleCircle.fromJson(c))
          .toList();
      return circles;
    }
    throw Exception('Failed to fetch circles');
  }

  /// Get circles by type
  Future<List<MeengleCircle>> getCirclesByType(CircleType type) async {
    final token = await _getToken();
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/discover?type=${type.toString().split('.').last}');
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final circles = (data['circles'] as List)
          .map((c) => MeengleCircle.fromJson(c))
          .toList();
      return circles;
    }
    return [];
  }

  /// Search circles
  Future<List<MeengleCircle>> searchCircles(String query) async {
    final token = await _getToken();
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/search?q=$query');
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final circles = (data['circles'] as List)
          .map((c) => MeengleCircle.fromJson(c))
          .toList();
      return circles;
    }
    return [];
  }

  /// Get user's circles
  Future<List<MeengleCircle>> getUserCircles(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/user/$userId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final circles = (data['circles'] as List)
          .map((c) => MeengleCircle.fromJson(c))
          .toList();
      return circles;
    }
    return [];
  }

  /// Join circle
  Future<CircleMembership> joinCircle({
    required String userId,
    required String circleId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/$circleId/join');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return CircleMembership(
        id: circleId,
        userId: userId,
        circleId: circleId,
        joinedAt: DateTime.now(),
      );
    }
    throw Exception('Failed to join circle');
  }

  /// Leave circle
  Future<void> leaveCircle({
    required String userId,
    required String circleId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/$circleId/leave');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to leave circle');
    }
  }

  /// Get circle members
  Future<List<String>> getCircleMembers(String circleId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/$circleId/members');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final members = List<String>.from(data['members'] ?? []);
      return members;
    }
    return [];
  }

  /// Get circle feed
  Future<List<Map<String, dynamic>>> getCircleFeed(String circleId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/$circleId/feed');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final posts = (data['posts'] as List)
          .map((p) => Map<String, dynamic>.from(p))
          .toList();
      return posts;
    }
    return [];
  }

  /// Post to circle
  Future<void> postToCircle({
    required String userId,
    required String circleId,
    required String content,
    List<String>? imageUrls,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/circles/$circleId/feed');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'imageUrls': imageUrls ?? [],
      }),
    );
    
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to post to circle');
    }
  }

  /// Create custom circle
  Future<MeengleCircle> createCustomCircle({
    required String userId,
    required String name,
    required String description,
    required CircleType type,
    required List<String> tags,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/circles');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'type': type.toString().split('.').last,
        'tags': tags,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleCircle.fromJson(data['circle']);
    }
    throw Exception('Failed to create circle');
  }
}

