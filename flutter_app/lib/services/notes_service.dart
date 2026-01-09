import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meengle_note.dart';
import 'api.dart';

class NotesService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Get notes for a specific user
  Future<List<MeengleNote>> getNotesForUser(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final url = Uri.parse('${ApiService.baseUrl}/api/notes/$userId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final notes = (data['notes'] as List?)
              ?.map((n) => MeengleNote.fromJson(n as Map<String, dynamic>))
              .toList() ??
              [];
          return notes;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  /// Post a new note to a user
  Future<MeengleNote?> postNote(String targetUserId, String content, {String type = 'comment'}) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final url = Uri.parse('${ApiService.baseUrl}/api/notes');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'targetUserId': targetUserId,
          'content': content,
          'type': type,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MeengleNote.fromJson(data['note'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error posting note: $e');
      return null;
    }
  }

  /// Like a note
  Future<MeengleNote?> likeNote(String noteId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final url = Uri.parse('${ApiService.baseUrl}/api/notes/$noteId/like');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MeengleNote.fromJson(data['note'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error liking note: $e');
      return null;
    }
  }

  /// Reply to a note
  Future<MeengleNote?> replyToNote(String noteId, String content) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final url = Uri.parse('${ApiService.baseUrl}/api/notes/$noteId/reply');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MeengleNote.fromJson(data['reply'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error replying to note: $e');
      return null;
    }
  }

  /// Delete a note
  Future<bool> deleteNote(String noteId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final url = Uri.parse('${ApiService.baseUrl}/api/notes/$noteId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting note: $e');
      return false;
    }
  }
}
