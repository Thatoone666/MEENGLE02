import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_profile.dart';

/// Service for voice messaging
class VoiceMessageService {
  final String baseUrl;
  String? _authToken;

  VoiceMessageService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Upload voice message
  Future<VoiceMessage?> uploadVoiceMessage({
    required String chatId,
    required String senderId,
    required String audioPath,
    required int durationSeconds,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/messages/voice/upload'),
      );

      request.headers.addAll(_headers);
      request.fields['chatId'] = chatId;
      request.fields['senderId'] = senderId;
      request.fields['durationSeconds'] = durationSeconds.toString();
      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        final message = VoiceMessage(
          id: data['id'],
          chatId: data['chatId'],
          senderId: data['senderId'],
          audioUrl: data['audioUrl'],
          durationSeconds: data['durationSeconds'],
          sentAt: DateTime.parse(data['sentAt']),
          isListened: data['isListened'] ?? false,
        );
        debugPrint('[VoiceMessageService] Voice message uploaded');
        return message;
      }
      return null;
    } catch (e) {
      debugPrint('[VoiceMessageService] Upload error: $e');
      return null;
    }
  }

  /// Mark voice message as listened
  Future<bool> markAsListened(String messageId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/voice/$messageId/listened'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('[VoiceMessageService] Marked as listened');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[VoiceMessageService] Mark listened error: $e');
      return false;
    }
  }

  /// Get chat voice messages
  Future<List<VoiceMessage>> getChatVoiceMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/voice/chat/$chatId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List)
            .map((m) => VoiceMessage(
                  id: m['id'],
                  chatId: m['chatId'],
                  senderId: m['senderId'],
                  audioUrl: m['audioUrl'],
                  durationSeconds: m['durationSeconds'],
                  sentAt: DateTime.parse(m['sentAt']),
                  isListened: m['isListened'] ?? false,
                ))
            .toList();
        debugPrint('[VoiceMessageService] Retrieved ${messages.length} voice messages');
        return messages;
      }
      return [];
    } catch (e) {
      debugPrint('[VoiceMessageService] Get messages error: $e');
      return [];
    }
  }

  /// Delete voice message
  Future<bool> deleteVoiceMessage(String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/messages/voice/$messageId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        debugPrint('[VoiceMessageService] Message deleted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[VoiceMessageService] Delete error: $e');
      return false;
    }
  }
}
