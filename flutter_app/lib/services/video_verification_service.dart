import 'dart:convert';
import 'api.dart';

class VideoVerificationService {
  /// Start a verification job. Returns jobId and expiry.
  static Future<Map<String, dynamic>> startVerification() async {
    final uri = Uri.parse('${ApiService.baseUrl}/verify/video/start');
    final res = await ApiService.client
        .post(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Could not start verification: ${res.statusCode}');
  }

  /// Upload video for job
  static Future<bool> uploadVideo(
      String jobId, String filePath, String filename) async {
    // Use ApiService.uploadFile for multipart handling
    final url = await ApiService.uploadFile(filePath, filename);
    return url != null;
  }

  /// Poll job status
  static Future<Map<String, dynamic>> status(String jobId) async {
    final uri = Uri.parse('${ApiService.baseUrl}/verify/video/$jobId');
    final res = await ApiService.client
        .get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Status error: ${res.statusCode}');
  }
}
