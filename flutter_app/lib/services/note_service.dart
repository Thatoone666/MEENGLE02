import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meengle_flutter/models/meengle_note.dart';
import 'api.dart';

/// Service for managing Meengle Notes
class NoteService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Post a note on someone's profile
  Future<MeengleNote> postNote({
    required String fromUserId,
    required String toUserId,
    required String content,
    required NoteType type,
    required bool isAnonymous,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    if (content.length > 280) {
      throw Exception('Note content must be 280 characters or less');
    }
    
    final url = Uri.parse('${ApiService.baseUrl}/notes');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'toUserId': toUserId,
        'content': content,
        'type': type.toString().split('.').last,
        'isAnonymous': isAnonymous,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleNote.fromJson(data['note']);
    }
    throw Exception('Failed to post note: ${response.body}');
  }

  /// Get notes on user's profile
  Future<List<MeengleNote>> getNotesOnProfile(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/notes/$userId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final notes = (data['notes'] as List)
          .map((n) => MeengleNote.fromJson(n))
          .toList();
      return notes;
    }
    throw Exception('Failed to fetch notes');
  }

  /// Get notes posted by user
  Future<List<MeengleNote>> getNotesByUser(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/notes/by/$userId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final notes = (data['notes'] as List)
          .map((n) => MeengleNote.fromJson(n))
          .toList();
      return notes;
    }
    return [];
  }

  /// Like a note
  Future<MeengleNote> likeNote(String noteId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/notes/$noteId/like');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleNote.fromJson(data['note'] ?? data);
    }
    throw Exception('Failed to like note');
  }

  /// Reply to a note
  Future<MeengleNote> replyToNote({
    required String parentNoteId,
    required String fromUserId,
    required String toUserId,
    required String content,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    if (content.length > 280) {
      throw Exception('Note content must be 280 characters or less');
    }
    
    final url = Uri.parse('${ApiService.baseUrl}/notes/$parentNoteId/reply');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'toUserId': toUserId,
        'content': content,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleNote.fromJson(data['note']);
    }
    throw Exception('Failed to reply to note');
  }

  /// Delete note
  Future<void> deleteNote(String noteId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/notes/$noteId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
  }

  /// Report note
  Future<void> reportNote(String noteId, String reason) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/notes/$noteId/report');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to report note');
    }
  }

  /// Block user from leaving notes
  Future<void> blockUserFromNotes(
    String userId,
    String blockedUserId,
  ) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/notes/block/$blockedUserId');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to block user');
    }
  }
}
