import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meengle_flutter/models/meengle_date.dart';
import 'api.dart';

/// Service for managing Meengle Dates
class DateService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Get all date ideas
  Future<List<MeengleDate>> getAllDateIdeas() async {
    final token = await _getToken();
    
    final url = Uri.parse('${ApiService.baseUrl}/dates/suggestions');
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dates = (data['suggestions'] as List)
          .map((d) => MeengleDate.fromJson(d))
          .toList();
      return dates;
    }
    return [];
  }

  /// Get date ideas by category
  Future<List<MeengleDate>> getDateIdeasByCategory(
    DateCategory category,
  ) async {
    final token = await _getToken();
    
    final url = Uri.parse(
      '${ApiService.baseUrl}/dates/suggestions?category=${category.toString().split('.').last}'
    );
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dates = (data['suggestions'] as List)
          .map((d) => MeengleDate.fromJson(d))
          .toList();
      return dates;
    }
    return [];
  }

  /// Get AI-recommended date ideas for a match
  Future<List<MeengleDate>> getRecommendedDateIdeas({
    required String userId,
    required String matchId,
    int count = 5,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse(
      '${ApiService.baseUrl}/dates/suggestions?matchId=$matchId&limit=$count'
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dates = (data['suggestions'] as List)
          .map((d) => MeengleDate.fromJson(d))
          .toList();
      return dates;
    }
    return [];
  }

  /// Search date ideas
  Future<List<MeengleDate>> searchDateIdeas(String query) async {
    final token = await _getToken();
    
    final url = Uri.parse(
      '${ApiService.baseUrl}/dates/suggestions?search=$query'
    );
    final response = await http.get(
      url,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dates = (data['suggestions'] as List)
          .map((d) => MeengleDate.fromJson(d))
          .toList();
      return dates;
    }
    return [];
  }

  /// Suggest a date to a match
  Future<void> suggestDate({
    required String fromUserId,
    required String toUserId,
    required String dateId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/dates');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'matchId': toUserId,
        'title': dateId,
      }),
    );
    
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to suggest date');
    }
  }

  /// Save date to favorites
  Future<void> saveDateToFavorites(String userId, String dateId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/dates/$dateId/favorite');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Get user's favorite dates
  Future<List<MeengleDate>> getFavoriteDates(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/dates/favorites');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dates = (data['dates'] as List)
          .map((d) => MeengleDate.fromJson(d))
          .toList();
      return dates;
    }
    return [];
  }

  /// Get date history
  Future<List<MeengleDate>> getDateHistory(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/dates/history');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dates = (data['dates'] as List)
          .map((d) => MeengleDate.fromJson(d))
          .toList();
      return dates;
    }
    return [];
  }

  /// Accept date proposal
  Future<void> acceptDate(String dateId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/dates/$dateId/accept');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Decline date proposal
  Future<void> declineDate(String dateId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/dates/$dateId/decline');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Rate date idea
  Future<void> rateDateIdea({
    required String dateId,
    required int rating, // 1-5
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/dates/$dateId/rate');
    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': rating}),
    );
  }
}

