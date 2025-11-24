import 'package:digital_growth_charts_app/classes/app_config.dart';
import 'package:digital_growth_charts_app/services/auth/auth_provider.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class NativeAuth implements AuthProvider {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  @override
  Future<AuthData> login() async {
    final clientId = AppConfig.microsoftLoginClientId;
    final issuer = AppConfig.microsoftLoginIssuer;

    if (clientId == null) {
      throw Exception('Missing Microsoft Login Client ID');
    }

    if (issuer == null) {
      throw Exception('Missing Microsoft Login Issuer');
    }

    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        'uk.ac.rcpch.dgc-app-test://oauth-callback',
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint:
              'https://login.microsoftonline.com/$issuer/oauth2/v2.0/authorize',
          tokenEndpoint:
              'https://login.microsoftonline.com/$issuer/oauth2/v2.0/token',
          endSessionEndpoint:
              'https://login.microsoftonline.com/$issuer/oauth2/v2.0/logout',
        ),
        scopes: ['openid', 'profile', 'email'],
      ),
    );

    if (result.refreshToken == null) {
      throw Exception('Missing refresh token');
    }

    if (result.idToken == null) {
      throw Exception('Missing ID token');
    }

    return AuthData(result.refreshToken!, result.idToken!);
  }
}

AuthProvider getAuthProvider() {
  return NativeAuth();
}
