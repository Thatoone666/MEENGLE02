import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import '../web/web_utils.dart';

class MediaUploadService {
  static const int _maxImageSize = 1024; // Max width/height for images
  static const int _jpegQuality = 85; // JPEG compression quality
  
  final String _cdnUrl;
  final String _uploadApiUrl;
  final http.Client _client;

  MediaUploadService({
    String? cdnUrl,
    String? uploadApiUrl,
    http.Client? client,
  })  : _cdnUrl = cdnUrl ?? const String.fromEnvironment('CDN_URL'),
        _uploadApiUrl = uploadApiUrl ?? const String.fromEnvironment('UPLOAD_API_URL'),
        _client = client ?? http.Client();

  Future<String> uploadImage({
    required Uint8List imageData,
    required String userId,
    required void Function(double progress) onProgress,
  }) async {
    try {
      // Compress image
      final compressedImage = await _compressImage(imageData);
      
      // Prepare upload
      final uri = Uri.parse('$_uploadApiUrl/images');
      final request = http.MultipartRequest('POST', uri)
        ..fields['userId'] = userId
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            compressedImage,
            filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );

      // Track upload progress
      final completer = Completer<String>();
      final response = await request.send();
      
      int totalBytes = compressedImage.length;
      int bytesUploaded = 0;
      
      response.stream.listen(
        (List<int> chunk) {
          bytesUploaded += chunk.length;
          final progress = bytesUploaded / totalBytes;
          onProgress(progress);
        },
        onDone: () async {
          if (response.statusCode == 200) {
            final responseData = await response.stream.toBytes();
            final result = String.fromCharCodes(responseData);
            completer.complete(result);
          } else {
            completer.completeError('Upload failed: ${response.statusCode}');
          }
        },
        onError: completer.completeError,
        cancelOnError: true,
      );

      return await completer.future;
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      throw UploadException('Image upload failed', e.toString());
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageData) async {
    // Decode image
    final image = img.decodeImage(imageData);
    if (image == null) throw UploadException('Invalid image data');

    // Resize if needed
    img.Image processedImage = image;
    if (image.width > _maxImageSize || image.height > _maxImageSize) {
      if (image.width > image.height) {
        processedImage = img.copyResize(
          image,
          width: _maxImageSize,
          height: (image.height * (_maxImageSize / image.width)).round(),
        );
      } else {
        processedImage = img.copyResize(
          image,
          width: (image.width * (_maxImageSize / image.height)).round(),
          height: _maxImageSize,
        );
      }
    }

    // Encode as JPEG with quality setting
    return Uint8List.fromList(img.encodeJpg(processedImage, quality: _jpegQuality));
  }

  String getCdnUrl(String imageId) {
    return '$_cdnUrl/$imageId';
  }

  void dispose() {
    _client.close();
  }
}

class UploadException implements Exception {
  final String message;
  final String details;

  UploadException(this.message, [this.details = '']);

  @override
  String toString() => 'UploadException: $message${details.isNotEmpty ? '\nDetails: $details' : ''}';
}