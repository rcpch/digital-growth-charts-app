import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles environment variable loading for the app.
/// - Local dev: load `.env` from project root.
/// - CI/Release: use `--dart-define` (no `.env` bundled).
class AppConfig {
  static Future<void> init() async {
    final noDartDefines =
        const String.fromEnvironment('DGC_BASE_URL', defaultValue: '').isEmpty &&
            const String.fromEnvironment('DGC_API_KEY', defaultValue: '').isEmpty;

    if (noDartDefines && !kReleaseMode) {
      // Local development → load from .env
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        debugPrint("⚠️ .env not found: $e");
        dotenv.loadFromString();
      }
    } else {
      // Release or dart-defines provided → don't load file
      dotenv.loadFromString(); // ensures dotenv is initialized
    }
  }

  static String get apiUrl {
    const define = String.fromEnvironment('DGC_BASE_URL', defaultValue: '');
    if (define.isNotEmpty) return define;
    return dotenv.env['DGC_BASE_URL'] ?? '';
  }

  static String get apiKey {
    const define = String.fromEnvironment('DGC_API_KEY', defaultValue: '');
    if (define.isNotEmpty) return define;
    return dotenv.env['DGC_API_KEY'] ?? '';
  }
}

