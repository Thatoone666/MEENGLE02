/// Web utilities for handling platform-specific operations in web builds
library web_utils_web;

/// Utility class for web platform-specific functionality
class WebUtils {
  /// Handle web-specific errors with better logging
  static void handleWebError(Object error, StackTrace stackTrace) {
    // On web, we can't do as much with stack traces, but we log them
    print('Web Error: $error');
    print('StackTrace: $stackTrace');
  }

  /// Convert web errors to user-friendly messages
  static String getWebFriendlyErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString();
    }
    return 'An error occurred';
  }

  /// Check if we're running on web platform
  static bool isWebPlatform() => true;

  /// Log error with context
  static void logWebError(String context, Object error, StackTrace stackTrace) {
    print('[$context] Error: $error\nStack: $stackTrace');
  }
}
