import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/safety_center.dart';
import 'api.dart';

class SafetyService {
  final String baseUrl;
  String? _authToken;

  SafetyService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // Legacy ETA sharing method
  static Future<Map<String, dynamic>> shareEta(
      String from, String to, String etaIso,
      {Map<String, dynamic>? location}) async {
    final uri = Uri.parse('${ApiService.baseUrl}/api/safety/eta');
    final res = await ApiService.client.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'from': from, 'to': to, 'eta': etaIso, 'location': location}));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Share ETA failed: ${res.statusCode}');
  }

  // Verify identity with video or selfie
  Future<bool> submitVideoVerification(String videoPath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/safety/verify-identity'),
      );

      request.headers.addAll(_headers);
      request.files.add(
        await http.MultipartFile.fromPath('video', videoPath),
      );

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        debugPrint('[SafetyService] Video verification submitted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Video verification error: $e');
      return false;
    }
  }

  // Get verification status
  Future<Map<String, dynamic>?> getVerificationStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/safety/verification-status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('[SafetyService] Verification status retrieved');
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('[SafetyService] Verification status error: $e');
      return null;
    }
  }

  // Block a user
  Future<bool> blockUser(String userId, String? reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety/block-user'),
        headers: _headers,
        body: jsonEncode({
          'blocked_user_id': userId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[SafetyService] User blocked successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Block user error: $e');
      return false;
    }
  }

  // Unblock a user
  Future<bool> unblockUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety/unblock-user'),
        headers: _headers,
        body: jsonEncode({'blocked_user_id': userId}),
      );

      if (response.statusCode == 200) {
        debugPrint('[SafetyService] User unblocked successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Unblock user error: $e');
      return false;
    }
  }

  // Get blocked users
  Future<List<BlockedUser>> getBlockedUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/safety/blocked-users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = (data['blocked_users'] as List)
            .map((u) => BlockedUser(
                  id: u['id'],
                  name: u['name'],
                  profileImage: u['profile_image'],
                  blockedAt: DateTime.parse(u['blocked_at']),
                  reason: u['reason'],
                ))
            .toList();
        debugPrint('[SafetyService] Retrieved ${users.length} blocked users');
        return users;
      }
      return [];
    } catch (e) {
      debugPrint('[SafetyService] Get blocked users error: $e');
      return [];
    }
  }

  // Report a user
  Future<bool> reportUser({
    required String userId,
    required String category,
    required String description,
    List<String>? mediaUrls,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety/report-user'),
        headers: _headers,
        body: jsonEncode({
          'reported_user_id': userId,
          'category': category,
          'description': description,
          'media_urls': mediaUrls,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[SafetyService] User report submitted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Report user error: $e');
      return false;
    }
  }

  // Add emergency contact
  Future<bool> addEmergencyContact({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety/emergency-contacts'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('[SafetyService] Emergency contact added');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Add emergency contact error: $e');
      return false;
    }
  }

  // Get emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/safety/emergency-contacts'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contacts = (data['emergency_contacts'] as List)
            .map((c) => EmergencyContact(
                  id: c['id'],
                  name: c['name'],
                  phoneNumber: c['phone_number'],
                  isVerified: c['is_verified'] ?? false,
                ))
            .toList();
        debugPrint('[SafetyService] Retrieved ${contacts.length} emergency contacts');
        return contacts;
      }
      return [];
    } catch (e) {
      debugPrint('[SafetyService] Get emergency contacts error: $e');
      return [];
    }
  }

  // Remove emergency contact
  Future<bool> removeEmergencyContact(String contactId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/safety/emergency-contacts/$contactId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('[SafetyService] Emergency contact removed');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Remove emergency contact error: $e');
      return false;
    }
  }

  // Share live location with emergency contact
  Future<bool> shareLiveLocation({
    required String contactId,
    required int durationMinutes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety/share-location'),
        headers: _headers,
        body: jsonEncode({
          'contact_id': contactId,
          'duration_minutes': durationMinutes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[SafetyService] Location sharing activated');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Share location error: $e');
      return false;
    }
  }

  // Stop location sharing
  Future<bool> stopLocationSharing(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety/stop-location-sharing'),
        headers: _headers,
        body: jsonEncode({'session_id': sessionId}),
      );

      if (response.statusCode == 200) {
        debugPrint('[SafetyService] Location sharing stopped');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SafetyService] Stop location sharing error: $e');
      return false;
    }
  }

  // Get safety tips
  Future<List<SafetyTip>> getSafetyTips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/safety/tips'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tips = (data['tips'] as List)
            .map((t) => SafetyTip(
                  id: t['id'],
                  title: t['title'],
                  content: t['content'],
                  category: t['category'],
                  icon: _getIconForCategory(t['category']),
                  createdAt: DateTime.parse(t['created_at']),
                ))
            .toList();
        debugPrint('[SafetyService] Retrieved ${tips.length} safety tips');
        return tips;
      }
      return [];
    } catch (e) {
      debugPrint('[SafetyService] Get safety tips error: $e');
      return [];
    }
  }

  // Get trust score
  Future<Map<String, dynamic>?> getTrustScore() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/safety/trust-score'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('[SafetyService] Trust score retrieved');
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('[SafetyService] Get trust score error: $e');
      return null;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'dating-tips':
        return Icons.favorite;
      case 'personal-safety':
        return Icons.security;
      case 'privacy':
        return Icons.privacy_tip;
      case 'communication':
        return Icons.message;
      case 'meetup':
        return Icons.location_on;
      case 'verification':
        return Icons.verified;
      default:
        return Icons.lightbulb;
    }
  }
}
