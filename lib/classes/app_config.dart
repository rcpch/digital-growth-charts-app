import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static bool _dotenvLoadedFromFile = false; // Track if .env was loaded

  static Future<void> init() async {
    final bool hasDartDefines =
        const String.fromEnvironment('DGC_BASE_URL', defaultValue: '').isNotEmpty &&
            const String.fromEnvironment('DGC_API_KEY', defaultValue: '').isNotEmpty;

    if (hasDartDefines) {
      debugPrint('AppConfig: Using dart-defines. Not loading .env file.');
      // No need to initialize dotenv if getters always check dart-defines first
      // and only fallback to dotenv.env if _dotenvLoadedFromFile is true.
      _dotenvLoadedFromFile = false;
    } else if (!kReleaseMode) {
      // No dart-defines AND in debug mode (likely local development)
      try {
        await dotenv.load(fileName: ".env");
        _dotenvLoadedFromFile = true; // Mark that it was loaded
        debugPrint('AppConfig: Loaded from .env file.');
      } catch (e) {
        debugPrint("AppConfig: ⚠️ .env file load failed (expected in local dev): $e");
        _dotenvLoadedFromFile = false;
      }
    } else {
      // No dart-defines AND in RELEASE mode
      debugPrint('AppConfig: CRITICAL - In release mode but DGC_BASE_URL or DGC_API_KEY not provided via dart-define.');
      _dotenvLoadedFromFile = false;
    }
  }

  static String get apiUrl {
    const String define = String.fromEnvironment('DGC_BASE_URL', defaultValue: '');
    if (define.isNotEmpty) return define;
    // Only access dotenv.env if we explicitly loaded from a file
    return _dotenvLoadedFromFile ? (dotenv.env['DGC_BASE_URL'] ?? '') : '';
  }

  static String get apiKey {
    const String define = String.fromEnvironment('DGC_API_KEY', defaultValue: '');
    if (define.isNotEmpty) return define;
    // Only access dotenv.env if we explicitly loaded from a file
    return _dotenvLoadedFromFile ? (dotenv.env['DGC_API_KEY'] ?? '') : '';
  }
}
