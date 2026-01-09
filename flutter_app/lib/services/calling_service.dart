import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for in-app voice and video calling
class CallingService {
  final String baseUrl;
  String? _authToken;
  final Map<String, dynamic> _activeCall = {};

  CallingService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Initiate video call
  Future<Map<String, dynamic>?> initiateVideoCall(String recipientId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calls/video/initiate'),
        headers: _headers,
        body: jsonEncode({'recipientId': recipientId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _activeCall.addAll(data);
        debugPrint('[CallingService] Video call initiated: ${data['callId']}');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[CallingService] Video call initiate error: $e');
      return null;
    }
  }

  /// Initiate audio call
  Future<Map<String, dynamic>?> initiateAudioCall(String recipientId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calls/audio/initiate'),
        headers: _headers,
        body: jsonEncode({'recipientId': recipientId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _activeCall.addAll(data);
        debugPrint('[CallingService] Audio call initiated: ${data['callId']}');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[CallingService] Audio call initiate error: $e');
      return null;
    }
  }

  /// Accept call
  Future<bool> acceptCall(String callId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calls/$callId/accept'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('[CallingService] Call accepted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[CallingService] Accept call error: $e');
      return false;
    }
  }

  /// Reject call
  Future<bool> rejectCall(String callId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calls/$callId/reject'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('[CallingService] Call rejected');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[CallingService] Reject call error: $e');
      return false;
    }
  }

  /// End call
  Future<bool> endCall(String callId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calls/$callId/end'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _activeCall.clear();
        debugPrint('[CallingService] Call ended');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[CallingService] End call error: $e');
      return false;
    }
  }

  /// Check call availability
  Future<bool> isUserAvailable(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calls/availability/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('[CallingService] Check availability error: $e');
      return false;
    }
  }

  /// Get active call info
  Map<String, dynamic> get getActiveCall => _activeCall;

  /// Check if in call
  bool get isInCall => _activeCall.isNotEmpty;
}
