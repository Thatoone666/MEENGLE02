import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meengle_flutter/models/meengle_moment.dart';
import 'api.dart';

/// Service for managing Meengle Moments (time-pressure matching)
class MomentService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Create a new moment for a match
  Future<MeengleMoment> createMoment({
    required String userId,
    required String matchId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/moments');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'matchId': matchId,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleMoment.fromJson(data['moment']);
    }
    throw Exception('Failed to create moment: ${response.body}');
  }

  /// Get active moments for user
  Future<List<MeengleMoment>> getActiveMoments() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/moments');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final moments = (data['moments'] as List)
          .map((m) => MeengleMoment.fromJson(m))
          .toList();
      return moments;
    }
    throw Exception('Failed to fetch moments');
  }

  /// Get expired moments
  Future<List<MeengleMoment>> getExpiredMoments(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/moments/expired');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final moments = (data['moments'] as List)
          .map((m) => MeengleMoment.fromJson(m))
          .toList();
      return moments;
    }
    return [];
  }

  /// Respond to moment
  Future<MeengleMoment> respondToMoment({
    required String momentId,
    required bool accept,
    String? message,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/moments/$momentId/accept');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'accepted': accept,
        'message': message,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleMoment.fromJson(data['moment'] ?? data);
    }
    throw Exception('Failed to respond to moment');
  }

  /// Extend moment by 6 hours
  Future<MeengleMoment> extendMoment(String momentId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/moments/$momentId/extend');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleMoment.fromJson(data['moment'] ?? data);
    }
    throw Exception('Failed to extend moment');
  }

  /// Get moment statistics
  Future<MomentStats> getMomentStats(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/moments/stats');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MomentStats(
        totalMoments: data['totalMoments'] ?? 0,
        acceptanceRate: (data['acceptanceRate'] ?? 0).toDouble(),
        averageResponseTime: Duration(minutes: data['avgResponseMinutes'] ?? 0),
      );
    }
    return MomentStats(totalMoments: 0, acceptanceRate: 0, averageResponseTime: Duration.zero);
  }

  /// Mark moment as viewed
  Future<void> markMomentAsViewed(String momentId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/moments/$momentId/view');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}

/// Moment statistics
class MomentStats {
  final int totalMoments;
  final double acceptanceRate; // 0-100%
  final Duration averageResponseTime;

  MomentStats({
    required this.totalMoments,
    required this.acceptanceRate,
    required this.averageResponseTime,
  });
}
