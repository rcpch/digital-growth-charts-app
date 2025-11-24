import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:digital_growth_charts_app/classes/app_config.dart';
import '/classes/log_levels.dart';

import "auth_stub.dart"
    if (dart.library.html) "web_auth.dart"
    if (dart.library.io) "native_auth.dart";

class AuthData {
  final String _idToken;
  final String _refreshToken;

  AuthData(this._idToken, this._refreshToken);

  String get idToken => _idToken;
  String get refreshToken => _refreshToken;

  String get email {
    // TODO MRB: verify the token. Very important even though the backend does it too.
    // https://github.com/rcpch/digital-growth-charts-app/issues/39
    final jwt = JWT.decode(_idToken);
    return jwt.payload['email'] as String;
  }
}

abstract class AuthProvider {
  Future<AuthData> login();

  factory AuthProvider() => getAuthProvider();
}

class AuthProviderWrapper {
  final storage = FlutterSecureStorage();
  final AuthProvider _authProvider;

  AuthProviderWrapper(this._authProvider);

  Future<AuthData?> load() async {
    final idToken = await storage.read(key: 'id_token');
    final refreshToken = await storage.read(key: 'refresh_token');
    
    if (idToken != null && refreshToken != null) {
      return AuthData(idToken, refreshToken);
    }

    return null;
  }

  Future<AuthData> login() async {
    final authData = await _authProvider.login();

    if (AppConfig.storageUrl != null && AppConfig.microsoftLoginOAuthServer != null) {
      final url = Uri.parse('${AppConfig.storageUrl}/api/token');
      final requestBody = {
        'oauth_server': AppConfig.microsoftLoginOAuthServer,
        'id_token': authData.idToken
      };

      print(authData.idToken);

      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody), // Encode the Map to a JSON string
        );

        if (response.statusCode == 200) {
          // API call successful, parse the JSON response
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          print('Token storage response: $responseData');
        } else {
          throw Exception('${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        // Handle any exceptions during the API call (e.g., network errors)
        developer.log(
          'Error submitting growth data: $e',
          level: LogLevel.warning,
          name: 'DigitalGrowthChartsService',
          error: e,
          stackTrace: StackTrace.current,
        );

        rethrow; // Rethrow the exception to be handled by the caller
      }
    }

    await storage.write(key: 'id_token', value: authData.idToken);
    await storage.write(key: 'refresh_token', value: authData.refreshToken);

    return authData;
  }

  Future<void> logout() async {
    await storage.delete(key: 'id_token');
    await storage.delete(key: 'refresh_token');
  }
}
