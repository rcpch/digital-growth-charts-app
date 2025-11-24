import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("AppConfig: CRITICAL ⚠️ .env file load failed: $e");
    }
  }

  static String get apiUrl {
    return (dotenv.env['DGC_BASE_URL'] ?? '');
  }

  static String get apiKey {
    return (dotenv.env['DGC_API_KEY'] ?? '');
  }

  static String? get storageUrl {
    return dotenv.env['DGC_STORAGE_BASE_URL'];
  }

  static String? get microsoftLoginClientId {
    return dotenv.env['MICROSOFT_LOGIN_CLIENT_ID'];
  }

  static String? get microsoftLoginOAuthServer {
    return dotenv.env['MICROSOFT_LOGIN_OAUTH_SERVER'];
  }
}
