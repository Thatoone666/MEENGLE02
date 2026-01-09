import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for AI-based photo verification
class PhotoVerificationService {
  final String baseUrl;
  String? _authToken;

  PhotoVerificationService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Submit photo for verification against ID
  Future<Map<String, dynamic>?> verifyPhotoAgainstID({
    required String userId,
    required String photoPath,
    required String idPhotoPath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verification/photo-id-match'),
      );

      request.headers.addAll(_headers);
      request.fields['userId'] = userId;
      request.files.add(await http.MultipartFile.fromPath('profilePhoto', photoPath));
      request.files.add(await http.MultipartFile.fromPath('idPhoto', idPhotoPath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        debugPrint('[PhotoVerification] Match score: ${data['matchScore']}');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[PhotoVerification] Verify error: $e');
      return null;
    }
  }

  /// Verify photo authenticity (detect deepfakes/filters)
  Future<Map<String, dynamic>?> verifyPhotoAuthenticity({
    required String userId,
    required String photoPath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verification/photo-authenticity'),
      );

      request.headers.addAll(_headers);
      request.fields['userId'] = userId;
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        debugPrint('[PhotoVerification] Authenticity: ${data['isAuthentic']}');
        return data; // Contains isAuthentic, confidence, risks
      }
      return null;
    } catch (e) {
      debugPrint('[PhotoVerification] Authenticity error: $e');
      return null;
    }
  }

  /// Get photo verification status
  Future<Map<String, dynamic>?> getPhotoVerificationStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verification/photo-status/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[PhotoVerification] Get status error: $e');
      return null;
    }
  }

  /// Batch verify multiple photos
  Future<List<Map<String, dynamic>>> batchVerifyPhotos({
    required String userId,
    required List<String> photoPaths,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verification/batch-verify'),
      );

      request.headers.addAll(_headers);
      request.fields['userId'] = userId;
      request.fields['count'] = photoPaths.length.toString();

      for (int i = 0; i < photoPaths.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('photos', photoPaths[i], filename: 'photo_$i'),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final results = List<Map<String, dynamic>>.from(data['results']);
        debugPrint('[PhotoVerification] Batch verified ${results.length} photos');
        return results;
      }
      return [];
    } catch (e) {
      debugPrint('[PhotoVerification] Batch verify error: $e');
      return [];
    }
  }
}
