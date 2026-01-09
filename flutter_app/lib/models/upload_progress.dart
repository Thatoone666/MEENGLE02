class UploadProgress {
  final double progress;
  final int bytesUploaded;
  final int totalBytes;
  final String? cdnUrl;
  final String? error;
  final Map<String, dynamic>? metadata;

  const UploadProgress({
    required this.progress,
    required this.bytesUploaded,
    required this.totalBytes,
    this.cdnUrl,
    this.error,
    this.metadata,
  });

  bool get isComplete => progress >= 1.0 && cdnUrl != null;
  bool get hasError => error != null;

  double get percentComplete => (progress * 100).roundToDouble();
  
  String get formattedProgress {
    final uploaded = _formatBytes(bytesUploaded);
    final total = _formatBytes(totalBytes);
    return '$uploaded / $total (${percentComplete.toStringAsFixed(1)}%)';
  }

  String _formatBytes(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double value = bytes.toDouble();
    
    while (value > 1024 && i < suffixes.length - 1) {
      value /= 1024;
      i++;
    }
    
    return '${value.toStringAsFixed(1)} ${suffixes[i]}';
  }

  UploadProgress copyWith({
    double? progress,
    int? bytesUploaded,
    int? totalBytes,
    String? cdnUrl,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return UploadProgress(
      progress: progress ?? this.progress,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      totalBytes: totalBytes ?? this.totalBytes,
      cdnUrl: cdnUrl ?? this.cdnUrl,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }
}