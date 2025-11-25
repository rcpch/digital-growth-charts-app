import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:digital_growth_charts_app/classes/app_config.dart';
import 'package:digital_growth_charts_app/services/auth/auth_provider.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import '/classes/log_levels.dart';

class NativeAuth implements AuthProvider {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  @override
  Future<AuthProviderTokens> login() async {
    final clientId = AppConfig.microsoftLoginClientId;
    final oauthServer = AppConfig.microsoftLoginOAuthServer;

    if (clientId == null) {
      throw Exception('Missing Microsoft Login Client ID');
    }

    if (oauthServer == null) {
      throw Exception('Missing Microsoft Login OAuth Server');
    }

    final url = Uri.parse('$oauthServer/.well-known/openid-configuration');

    String authorizationEndpoint = '';
    String tokenEndpoint = '';
    String endSessionEndpoint = '';

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        authorizationEndpoint = responseData['authorization_endpoint'] as String;
        tokenEndpoint = responseData['token_endpoint'] as String;
        endSessionEndpoint = responseData['end_session_endpoint'] as String;
      } else {
        throw Exception('${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions during the API call (e.g., network errors)
      developer.log(
        'Error fetching Open ID configuration document: $e',
        level: LogLevel.warning,
        name: 'NativeAuth',
        error: e,
        stackTrace: StackTrace.current,
      );

      rethrow; // Rethrow the exception to be handled by the caller
    }

    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        'uk.ac.rcpch.dgc-app-test://oauth-callback',
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: authorizationEndpoint,
          tokenEndpoint: tokenEndpoint,
          endSessionEndpoint: endSessionEndpoint,
        ),
        scopes: ['openid', 'profile', 'email', 'offline_access'],
      ),
    );

    if (result.refreshToken == null) {
      throw Exception('Missing refresh token');
    }

    if (result.idToken == null) {
      throw Exception('Missing ID token');
    }

    return AuthProviderTokens(result.idToken!, result.refreshToken!);
  }
}

AuthProvider getAuthProvider() {
  return NativeAuth();
}
