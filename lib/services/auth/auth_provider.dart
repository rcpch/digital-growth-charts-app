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
  final String _refreshToken;
  final String? _accessToken;

  final String? _name;
  final String? _email;

  AuthData(this._refreshToken, this._accessToken, this._name, this._email);

  String get refreshToken => _refreshToken;
  String? get name => _name;
  String? get email => _email;
}

class AuthProviderTokens {
  final String idToken;
  final String refreshToken;

  AuthProviderTokens(this.idToken, this.refreshToken);
}

abstract class AuthProvider {
  Future<AuthProviderTokens> login();

  factory AuthProvider() => getAuthProvider();
}

class AuthProviderWrapper {
  final storage = FlutterSecureStorage();
  final AuthProvider _authProvider;

  AuthProviderWrapper(this._authProvider);

  Future<AuthData?> load() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    final accessToken = await storage.read(key: 'access_token');

    final name = await storage.read(key: 'name');
    final email = await storage.read(key: 'email');

    if (refreshToken != null) {
      return AuthData(refreshToken, accessToken, name, email);
    }

    return null;
  }

  Future<AuthData> login() async {
    final tokens = await _authProvider.login();

    String? accessToken;
    String? name;
    String? email;

    if (AppConfig.storageUrl != null && AppConfig.microsoftLoginOAuthServer != null) {
      final url = Uri.parse('${AppConfig.storageUrl}/api/token');
      final requestBody = {
        'oauth_server': AppConfig.microsoftLoginOAuthServer,
        'id_token': tokens.idToken
      };

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
          
          accessToken = responseData['access_token'] as String?;
          name = responseData['name'] as String?;
          email = responseData['email'] as String?;
        } else {
          throw Exception('${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        // Handle any exceptions during the API call (e.g., network errors)
        developer.log(
          'Error fetching token: $e',
          level: LogLevel.warning,
          name: 'StorageService',
          error: e,
          stackTrace: StackTrace.current,
        );

        rethrow; // Rethrow the exception to be handled by the caller
      }
    }

    if(accessToken != null) {
      await storage.write(key: 'access_token', value: accessToken);
    }

    if(name != null) {
      await storage.write(key: 'name', value: name);
    }

    if(email != null) {
      await storage.write(key: 'email', value: email);
    }

    await storage.write(key: 'refresh_token', value: tokens.refreshToken);

    return AuthData(tokens.refreshToken, accessToken, name, email);
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }
}
