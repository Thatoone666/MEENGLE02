import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image/image.dart' as img;
import 'package:meengle_flutter/services/media_service.dart';
import 'package:meengle_flutter/utils/logger.dart';
import 'package:meengle_flutter/models/upload_progress.dart';
import 'media_service_test.mocks.dart';

@GenerateMocks([http.Client, http.StreamedRequest])
void main() {
  late MediaService mediaService;
  late MockClient mockClient;
  late Logger logger;

  setUp(() {
    mockClient = MockClient();
    logger = Logger();
    mediaService = MediaService(client: mockClient, logger: logger);
  });

  group('MediaService', () {
    test('optimizes and uploads image correctly', () async {
      logger.info('Starting test');
      
      // Create a minimal test image
      final image = img.Image(width: 2, height: 2);
      image.setPixel(0, 0, img.ColorRgba8(255, 255, 255, 255));
      image.setPixel(1, 0, img.ColorRgba8(0, 0, 0, 255));
      image.setPixel(0, 1, img.ColorRgba8(0, 0, 0, 255));
      image.setPixel(1, 1, img.ColorRgba8(255, 255, 255, 255));
      final imageData = Uint8List.fromList(img.encodeJpg(image));
      
      logger.info('Image created');
      
      // Mock successful upload URL response
      when(mockClient.post(
        Uri.parse('https://api.meengle.app/media/upload-url'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) => Future.value(http.Response(
        json.encode({
          'uploadUrl': 'https://test.com/upload',
          'cdnPath': 'test/123',
        }),
        200,
        headers: {'Content-Type': 'application/json'},
      )));
      
      logger.info('URL mock setup');
      
      // Mock successful upload
      when(mockClient.send(any)).thenAnswer((_) => Future.value(
        http.StreamedResponse(
          Stream.value(utf8.encode('{"status": "success"}')),
          200,
          headers: {'Content-Type': 'application/json'},
        ),
      ));
      
      logger.info('Upload mock setup');

      try {
        UploadProgress? lastProgress;
        final String cdnUrl = await mediaService.uploadMedia(
          data: imageData,
          fileName: 'test.jpg',
          onProgress: (progress) {
            logger.info('Progress update: ${progress.progress}');
            lastProgress = progress;
          },
        );
        
        logger.info('Upload completed');

        expect(cdnUrl, startsWith('https://cdn.meengle.app/'));
        expect(lastProgress, isNotNull);
        expect(lastProgress!.isComplete, isTrue);
        expect(lastProgress!.progress, equals(1.0));
        
        logger.info('Expectations verified');
      } catch (e) {
        logger.error('Test failed', e);
        rethrow;
      } finally {
        // Verify API calls
        verify(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: any,
        )).called(1);
        
        verify(mockClient.send(any)).called(1);
        logger.info('Verification completed');
      }
    });

    test('handles upload errors gracefully', () async {
      // Create a small valid JPEG image
      final image = img.Image(width: 1, height: 1);
      image.setPixel(0, 0, img.ColorRgba8(255, 255, 255, 255));
      final imageData = Uint8List.fromList(img.encodeJpg(image));
      
      when(mockClient.post(
        any,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fileName': 'test.jpg',
          'contentType': 'image/jpeg',
        }),
      )).thenAnswer((_) async => http.Response(
        json.encode({'error': 'Internal Server Error'}),
        500,
        headers: {'Content-Type': 'application/json'},
      ));

      UploadProgress? lastProgress;
      await expectLater(
        () => mediaService.uploadMedia(
          data: imageData,
          fileName: 'test.jpg',
          onProgress: (progress) => lastProgress = progress,
        ),
        throwsException,
      );

      expect(lastProgress, isNotNull);
      expect(lastProgress!.hasError, isTrue);
      expect(lastProgress!.progress, equals(0.0));
    });

    test('generates correct image URLs', () {
      const imageId = 'test123';
      
      expect(
        mediaService.getImageUrl(imageId),
        equals('https://cdn.meengle.app/images/$imageId/md'),
      );
      
      expect(
        mediaService.getImageUrl(imageId, ImageSize.thumbnail),
        equals('https://cdn.meengle.app/images/$imageId/thumb'),
      );
      
      expect(
        mediaService.getImageUrl(imageId, ImageSize.large),
        equals('https://cdn.meengle.app/images/$imageId/lg'),
      );
    });
  });
}