import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_profile.dart';

/// Service for managing video profiles
class VideoProfileService {
  final String baseUrl;
  String? _authToken;

  VideoProfileService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Upload video profile
  Future<VideoProfile> uploadVideoProfile({
    required String userId,
    required String videoPath,
    required String thumbnailPath,
    required int durationSeconds,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/video-profiles/upload'),
      );

      request.headers.addAll(_headers);
      request.fields['userId'] = userId;
      request.fields['durationSeconds'] = durationSeconds.toString();

      request.files.add(await http.MultipartFile.fromPath('video', videoPath));
      request.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnailPath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        debugPrint('[VideoProfileService] Video uploaded successfully');
        return VideoProfile(
          id: data['id'],
          userId: data['userId'],
          videoUrl: data['videoUrl'],
          thumbnailUrl: data['thumbnailUrl'],
          durationSeconds: data['durationSeconds'],
          uploadedAt: DateTime.parse(data['uploadedAt']),
          viewCount: data['viewCount'] ?? 0,
          isActive: data['isActive'] ?? true,
        );
      }
      throw Exception('Failed to upload video');
    } catch (e) {
      debugPrint('[VideoProfileService] Upload error: $e');
      rethrow;
    }
  }

  /// Get user's video profile
  Future<VideoProfile?> getUserVideoProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/video-profiles/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoProfile(
          id: data['id'],
          userId: data['userId'],
          videoUrl: data['videoUrl'],
          thumbnailUrl: data['thumbnailUrl'],
          durationSeconds: data['durationSeconds'],
          uploadedAt: DateTime.parse(data['uploadedAt']),
          viewCount: data['viewCount'] ?? 0,
          isActive: data['isActive'] ?? true,
        );
      }
      return null;
    } catch (e) {
      debugPrint('[VideoProfileService] Get profile error: $e');
      return null;
    }
  }

  /// Delete video profile
  Future<bool> deleteVideoProfile(String videoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/video-profiles/$videoId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        debugPrint('[VideoProfileService] Video deleted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[VideoProfileService] Delete error: $e');
      return false;
    }
  }

  /// Increment view count
  Future<void> recordVideoView(String videoId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/video-profiles/$videoId/view'),
        headers: _headers,
      );
      debugPrint('[VideoProfileService] View recorded');
    } catch (e) {
      debugPrint('[VideoProfileService] Record view error: $e');
    }
  }
}
