// This file is conditionally imported for web only
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class WebUtils {
  static final _logger = Logger();

  static void handleWebError(dynamic error, StackTrace stackTrace) {
    if (!kIsWeb) return;
    
    // Log web-specific errors
    _logger.error('Web Error', error, stackTrace);
    
    // TODO: Send to error tracking service if needed
  }
}