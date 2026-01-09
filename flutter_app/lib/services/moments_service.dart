import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meengle_moment.dart';
import 'api.dart';

class MomentsService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Get all active moments for current user
  Future<List<MeengleMoment>> getActiveMoments() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final url = Uri.parse('${ApiService.baseUrl}/api/moments');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final moments = (data['moments'] as List?)
              ?.map((m) => MeengleMoment.fromJson(m as Map<String, dynamic>))
              .toList() ??
              [];
          return moments;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching moments: $e');
      return [];
    }
  }

  /// Accept a moment
  Future<MeengleMoment?> acceptMoment(String momentId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final url = Uri.parse('${ApiService.baseUrl}/api/moments/accept');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'momentId': momentId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MeengleMoment.fromJson(data['moment'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error accepting moment: $e');
      return null;
    }
  }

  /// Reject a moment
  Future<bool> rejectMoment(String momentId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = Uri.parse('${ApiService.baseUrl}/api/moments');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'momentId': momentId, 'action': 'reject'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error rejecting moment: $e');
      return false;
    }
  }

  /// Extend a moment's expiry time
  Future<MeengleMoment?> extendMoment(String momentId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final url = Uri.parse('${ApiService.baseUrl}/api/moments/$momentId/extend');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MeengleMoment.fromJson(data['moment'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error extending moment: $e');
      return null;
    }
  }
}
