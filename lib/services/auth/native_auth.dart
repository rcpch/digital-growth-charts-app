import 'package:digital_growth_charts_app/classes/app_config.dart';
import 'package:digital_growth_charts_app/services/auth/auth_provider.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

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

    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        'uk.ac.rcpch.dgc-app-test://oauth-callback',
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: '$oauthServer/authorize',
          tokenEndpoint: '$oauthServer/token',
          endSessionEndpoint:'$oauthServer/logout',
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

    return AuthProviderTokens(result.idToken!, result.refreshToken!);
  }
}

AuthProvider getAuthProvider() {
  return NativeAuth();
}
