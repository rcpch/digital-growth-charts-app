import 'package:flutter_dotenv/flutter_dotenv.dart';

// Handles the loading of environment variables (esp dGC credentials)
class AppConfig {
  static Future<void> init() async {
    // Try .env only in dev
    if (const String.fromEnvironment('DGC_BASE_URL', defaultValue: '') == '') {
      await dotenv.load(fileName: ".env");
    }
  }

  static String get apiUrl =>
      const String.fromEnvironment('DGC_BASE_URL', defaultValue: '') != ''
          ? const String.fromEnvironment('DGC_BASE_URL')
          : dotenv.env['DGC_BASE_URL'] ?? '';

  static String get apiKey =>
      const String.fromEnvironment('DGC_API_KEY', defaultValue: '') != ''
          ? const String.fromEnvironment('DGC_API_KEY')
          : dotenv.env['DGC_API_KEY'] ?? '';
}