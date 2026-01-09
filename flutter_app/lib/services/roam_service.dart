import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meengle_flutter/models/meengle_roam.dart';
import 'api.dart';

/// Service for managing Meengle Roam (travel + adventure)
class RoamService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Activate travel mode
  Future<MeengleRoam> activateTravelMode({
    required String userId,
    required String city,
    required double latitude,
    required double longitude,
    required List<String> travelInterests,
    required List<String> lookingFor,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/plan');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'destination': city,
        'latitude': latitude,
        'longitude': longitude,
        'interests': travelInterests,
        'lookingFor': lookingFor,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleRoam.fromJson(data['trip']);
    }
    throw Exception('Failed to activate travel mode');
  }

  /// Deactivate travel mode
  Future<void> deactivateTravelMode(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/deactivate');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Get user's active roam
  Future<MeengleRoam?> getUserActiveRoam(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/active');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['trip'] != null) {
        return MeengleRoam.fromJson(data['trip']);
      }
    }
    return null;
  }

  /// Get roam history
  Future<List<MeengleRoam>> getRoamHistory(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/history');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final trips = (data['trips'] as List)
          .map((t) => MeengleRoam.fromJson(t))
          .toList();
      return trips;
    }
    return [];
  }

  /// Find travel buddies in the area
  Future<List<String>> findTravelBuddies({
    required String userId,
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse(
      '${ApiService.baseUrl}/roam/discover?latitude=$latitude&longitude=$longitude&maxDistance=${radiusInKm ~/ 1000}'
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final buddies = List<String>.from(data['trips'] ?? []);
      return buddies;
    }
    return [];
  }

  /// Get local guides
  Future<List<LocalGuide>> getLocalGuides({
    required String city,
    String? specialty,
  }) async {
    final token = await _getToken();
    
    String url = '${ApiService.baseUrl}/roam/guides?city=$city';
    if (specialty != null) url += '&specialty=$specialty';
    
    final response = await http.get(
      Uri.parse(url),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final guides = (data['guides'] as List)
          .map((g) => LocalGuide.fromJson(g))
          .toList();
      return guides;
    }
    return [];
  }

  /// Get local events
  Future<List<LocalEvent>> getLocalEvents({
    required String city,
    String? category,
    int? maxResults,
  }) async {
    final token = await _getToken();
    
    String url = '${ApiService.baseUrl}/roam/events?city=$city';
    if (category != null) url += '&category=$category';
    if (maxResults != null) url += '&limit=$maxResults';
    
    final response = await http.get(
      Uri.parse(url),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final events = (data['events'] as List)
          .map((e) => LocalEvent.fromJson(e))
          .toList();
      return events;
    }
    return [];
  }

  /// Connect with local guide
  Future<void> connectWithGuide({
    required String userId,
    required String guideId,
    String? message,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/guides/$guideId/connect');
    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'message': message}),
    );
  }

  /// Attend local event
  Future<void> attendEvent({
    required String userId,
    required String eventId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/events/$eventId/attend');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Get user's roam network (people met while traveling)
  Future<List<String>> getRoamNetwork(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/network');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['network'] ?? []);
    }
    return [];
  }

  /// Share roam story/update
  Future<void> shareRoamUpdate({
    required String userId,
    required String message,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/updates');
    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
        'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
  }

  /// Get roam stories feed
  Future<List<Map<String, dynamic>>> getRoamFeed() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/feed');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['updates'] ?? []);
    }
    return [];
  }

  /// Update current location while in travel mode
  Future<void> updateCurrentLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/roam/location');
    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
      }),
    );
  }
}
