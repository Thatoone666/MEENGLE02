import 'package:flutter/foundation.dart';

class WebUtils {
  static void handleWebError(dynamic error, StackTrace stackTrace) {
    if (kIsWeb) {
      // Log error details for debugging
      // Uncomment for production logging:
      // debugPrint('Web error: $error');
      // debugPrint('Stack trace: $stackTrace');
    }
  }
  
  static Future<String?> getClientIp() async {
    // Implement web-specific IP detection if needed
    return null;
  }
}