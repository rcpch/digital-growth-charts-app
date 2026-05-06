import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class Analytics {
  static FirebaseAnalytics? _instance;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _instance = FirebaseAnalytics.instance;
      developer.log('Firebase Analytics initialised');
    } catch (e) {
      developer.log('Firebase Analytics unavailable: $e');
    }
  }

  static Future<void> logAppOpen() async {
    await _instance?.logAppOpen();
  }

  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _instance?.logEvent(name: name, parameters: parameters);
  }
}
