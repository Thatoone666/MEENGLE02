import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/media_upload_service.dart';

class MediaUploadWidget extends StatefulWidget {
  final String userId;
  final Function(String imageUrl) onUploadComplete;
  final Function(String error)? onError;
  final Widget? child;
  final double? size;
  final BorderRadius? borderRadius;
  
  const MediaUploadWidget({
    super.key,
    required this.userId,
    required this.onUploadComplete,
    this.onError,
    this.child,
    this.size,
    this.borderRadius,
  });

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  final _uploadService = MediaUploadService();
  double _uploadProgress = 0;
  bool _isUploading = false;

  Future<void> uploadImage(Uint8List imageData) async {
    if (_isUploading) return;

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0;
      });

      final imageId = await _uploadService.uploadImage(
        imageData: imageData,
        userId: widget.userId,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      final imageUrl = _uploadService.getCdnUrl(imageId);
      widget.onUploadComplete(imageUrl);
    } catch (e) {
      widget.onError?.call(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.child != null)
          widget.child!
        else
          Container(
            width: widget.size ?? 120,
            height: widget.size ?? 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined),
          ),
        if (_isUploading)
          Container(
            width: widget.size ?? 120,
            height: widget.size ?? 120,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: _uploadProgress,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_uploadProgress * 100).round()}%',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _uploadService.dispose();
    super.dispose();
  }
}