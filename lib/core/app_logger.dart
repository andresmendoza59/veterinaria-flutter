import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }

  static void warning(String message) {
    debugPrint('[WARNING] $message');
  }

  static void error(String message, {Object? error}) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint(error.toString());
  }
}
