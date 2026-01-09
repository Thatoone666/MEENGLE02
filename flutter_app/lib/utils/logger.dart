import 'package:flutter/foundation.dart';

class Logger {
  void info(String message, [dynamic data]) {
    if (kDebugMode) {
      print('[INFO] $message ${data ?? ''}');
    }
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) print(error);
      if (stackTrace != null) print(stackTrace);
    }
  }

  void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      print('[WARN] $message ${data ?? ''}');
    }
  }

  void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      print('[DEBUG] $message ${data ?? ''}');
    }
  }
}