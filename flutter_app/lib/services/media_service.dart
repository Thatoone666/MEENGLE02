import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/upload_progress.dart';
import '../utils/logger.dart';

/// The size variants available for images
enum ImageSize {
  /// 150x150
  thumbnail,
  /// 300x300
  small,
  /// 600x600
  medium,
  /// 1200x1200
  large,
  /// Original size
  original
}

/// Handles media operations like upload, optimization and URL generation.
class MediaService {
  static const String _cdnBaseUrl = 'https://cdn.meengle.app';
  static const String _apiBaseUrl = 'https://api.meengle.app';
  static const int _maxImageSize = 1024;
  static const int _compressionQuality = 85;

  final http.Client _client;
  final Logger _logger;

  MediaService({http.Client? client, Logger? logger})
      : _client = client ?? http.Client(),
        _logger = logger ?? Logger();

  /// Gets a signed URL for uploading media
  Future<Map<String, dynamic>> _getUploadUrl({
    required String fileName,
    required String contentType,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiBaseUrl/media/upload-url'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fileName': fileName,
          'contentType': contentType,
        }),
      );

      if (response.statusCode != 200) {
        _logger.error('Failed to get upload URL', response.statusCode);
        throw Exception('Failed to get upload URL');
      }

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Error getting upload URL', e);
      rethrow;
    }
  }

  /// Gets a CDN URL for an image with the specified size
  String getImageUrl(String imageId, [ImageSize size = ImageSize.medium]) {
    String sizeSuffix;
    switch (size) {
      case ImageSize.thumbnail:
        sizeSuffix = 'thumb';
        break;
      case ImageSize.small:
        sizeSuffix = 'sm';
        break;
      case ImageSize.medium:
        sizeSuffix = 'md';
        break;
      case ImageSize.large:
        sizeSuffix = 'lg';
        break;
      case ImageSize.original:
        sizeSuffix = 'orig';
        break;
    }
    return '$_cdnBaseUrl/images/$imageId/$sizeSuffix';
  }

  /// Uploads media to storage with progress tracking
  Future<String> uploadMedia({
    required Uint8List data,
    required String fileName,
    String contentType = 'image/jpeg',
    void Function(UploadProgress progress)? onProgress,
  }) async {
    try {
      Uint8List uploadData = data;

      if (contentType.startsWith('image/')) {
        // For images, optimize before upload
        uploadData = await _optimizeImage(data);
      }

      final uploadInfo = await _getUploadUrl(
        fileName: fileName,
        contentType: contentType,
      );

      final uploadUrl = uploadInfo['uploadUrl'] as String?;
      final cdnPath = uploadInfo['cdnPath'] as String?;

      if (uploadUrl == null || cdnPath == null) {
        _logger.error('Invalid upload URL response');
        throw Exception('Invalid upload URL response');
      }

      final request = http.StreamedRequest('PUT', Uri.parse(uploadUrl));
      request.headers['Content-Type'] = contentType;
      request.contentLength = uploadData.length;

      // Send all data at once with progress update
      request.sink.add(uploadData);
      onProgress?.call(UploadProgress(
        progress: 1.0,
        bytesUploaded: uploadData.length,
        totalBytes: uploadData.length,
      ));

      await request.sink.close();
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.toBytes();
      final response = http.Response.bytes(
        responseBody,
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
        request: request,
      );

      if (response.statusCode != 200) {
        _logger.error('Upload failed', response.statusCode);
        throw Exception('Upload failed');
      }

      final cdnUrl = '$_cdnBaseUrl/$cdnPath';
      onProgress?.call(UploadProgress(
        progress: 1.0,
        bytesUploaded: uploadData.length,
        totalBytes: uploadData.length,
        cdnUrl: cdnUrl,
      ));

      return cdnUrl;
    } catch (e) {
      _logger.error('Error during upload', e);
      onProgress?.call(UploadProgress(
        progress: 0,
        bytesUploaded: 0,
        totalBytes: data.length,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  /// Optimizes an image for upload by resizing and compressing it
  Future<Uint8List> _optimizeImage(Uint8List data) async {
    try {
      final image = img.decodeImage(data);
      if (image == null) {
        _logger.error('Failed to decode image');
        throw Exception('Failed to decode image');
      }

      var width = image.width;
      var height = image.height;

      if (width > _maxImageSize || height > _maxImageSize) {
        final ratio = _maxImageSize / (width > height ? width : height);
        width = (width * ratio).round();
        height = (height * ratio).round();

        final resized = img.copyResize(
          image,
          width: width,
          height: height,
          interpolation: img.Interpolation.linear,
        );

        _logger.info('Image resized', {
          'originalSize': '${image.width}x${image.height}',
          'newSize': '${width}x$height',
        });

        final optimized = img.encodeJpg(
          resized,
          quality: _compressionQuality,
        );

        _logger.info('Image optimized', {
          'originalSize': data.length,
          'optimizedSize': optimized.length,
          'compressionRatio': data.length / optimized.length,
        });

        return Uint8List.fromList(optimized);
      }

      // If no resizing needed, just optimize the original
      final optimized = img.encodeJpg(
        image,
        quality: _compressionQuality,
      );

      _logger.info('Image optimized', {
        'originalSize': data.length,
        'optimizedSize': optimized.length,
        'compressionRatio': data.length / optimized.length,
      });

      return Uint8List.fromList(optimized);
    } catch (e) {
      _logger.error('Error optimizing image', e);
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

