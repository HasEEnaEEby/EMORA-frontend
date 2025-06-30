import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class Logger {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    if (kDebugMode) {
      info('🐛 Debug mode logging enabled');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'EMORA_INFO', level: 800);
    }
  }

  static void error(String message, dynamic error, [StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'EMORA_ERROR',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void warning(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'EMORA_WARNING', level: 900);
    }
  }
}
