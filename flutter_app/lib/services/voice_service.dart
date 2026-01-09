import 'dart:typed_data';
import 'dart:convert';
import 'api.dart';

class VoiceService {
  static Future<Map<String, dynamic>> uploadVoice(
      String filePath, String filename) async {
    // Reuse ApiService.uploadFile for multipart
    final url = await ApiService.uploadFile(filePath, filename);
    return {'url': url};
  }

  static Future<Map<String, dynamic>> uploadSample(Uint8List bytes) async {
    // In a real implementation we'd write bytes to a temp file and call uploadVoice.
    // For the prototype, just call a fake endpoint via ApiService
    final token = await ApiService.getToken();
    final res = await ApiService.client.post(
        Uri.parse('${ApiService.baseUrl}/voice/upload-sample'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/octet-stream'
        },
        body: bytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('upload failed');
  }
}
