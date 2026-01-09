import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'api.dart';

/// Helper function to get filename from path
String _getFilename(String path) {
  return path.split(Platform.pathSeparator).last;
}

/// Media upload service for Stories and other features
class MediaUploadService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Compress image before upload
  Future<File> compressImage(File imageFile, {int quality = 80}) async {
    try {
      final originalImage = img.decodeImage(imageFile.readAsBytesSync());
      if (originalImage == null) return imageFile;

      final compressed = img.encodeJpg(originalImage, quality: quality);
      final compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressed);

      return compressedFile;
    } catch (e) {
      debugPrint('Compression error: $e');
      return imageFile; // Return original if compression fails
    }
  }

  /// Upload image for Story
  Future<String> uploadStoryImage(
    File imageFile, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      // Compress image first
      final compressed = await compressImage(imageFile);

      // Create multipart request
      final uri = Uri.parse('${ApiService.baseUrl}/media/upload-story');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            compressed.path,
            filename: _getFilename(imageFile.path),
          ),
        );

      // Track upload progress
      final streamResponse = await request.send();
      streamResponse.stream.listen(
        (event) {
          if (onProgress != null) {
            onProgress(streamResponse.contentLength ?? 0, 
                       streamResponse.contentLength ?? 0);
          }
        },
      );

      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['url'] ?? data['imageUrl'];
      }
      throw Exception('Upload failed: ${response.body}');
    } catch (e) {
      throw Exception('Failed to upload story image: $e');
    }
  }

  /// Upload profile photo
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final compressed = await compressImage(imageFile, quality: 85);

      final uri = Uri.parse('${ApiService.baseUrl}/media/upload-profile');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'photo',
            compressed.path,
            filename: _getFilename(imageFile.path),
          ),
        );

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['url'] ?? data['photoUrl'];
      }
      throw Exception('Upload failed');
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Validate image file
  bool validateImageFile(File file) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final filePath = file.path;
    final fileExtension = filePath.split('.').last.toLowerCase();
    
    if (!validExtensions.contains(fileExtension)) {
      throw Exception('Invalid image format. Allowed: jpg, png, gif');
    }

    final fileSizeInMB = file.lengthSync() / (1024 * 1024);
    if (fileSizeInMB > 10) {
      throw Exception('Image too large. Max size: 10MB');
    }

    return true;
  }

  /// Delete media file
  Future<void> deleteMediaFile(String mediaUrl) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('${ApiService.baseUrl}/media/delete');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'url': mediaUrl}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete media');
      }
    } catch (e) {
      debugPrint('Error deleting media: $e');
    }
  }

  /// Get upload progress stream
  Stream<int> getUploadProgress(File file) async* {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final fileSize = file.lengthSync();
      final chunkSize = 1024 * 1024; // 1MB chunks
      int uploaded = 0;

      while (uploaded < fileSize) {
        await Future.delayed(Duration(milliseconds: 100));
        uploaded += chunkSize;
        yield (uploaded * 100 / fileSize).toInt();
      }
    } catch (e) {
      debugPrint('Progress error: $e');
    }
  }
}
