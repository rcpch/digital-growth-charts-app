import 'package:digital_growth_charts_app/services/auth/auth_provider.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class NativeAuth implements AuthProvider {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  @override
  Future<AuthData> login() async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        '19f9ef35-8ed9-46c9-a9b8-f9acdb01ba53',
        'uk.ac.rcpch.dgc-app-test://oauth-callback',
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint:
              'https://login.microsoftonline.com/dd8f9931-cb78-4406-8a01-01ac61c10d4a/oauth2/v2.0/authorize',
          tokenEndpoint:
              'https://login.microsoftonline.com/dd8f9931-cb78-4406-8a01-01ac61c10d4a/oauth2/v2.0/token',
          endSessionEndpoint:
              'https://login.microsoftonline.com/dd8f9931-cb78-4406-8a01-01ac61c10d4a/oauth2/v2.0/logout',
        ),
        scopes: ['openid', 'profile', 'email'],
      ),
    );

    if (result.accessToken == null) {
      throw Exception('Missing access token');
    }

    if (result.idToken == null) {
      throw Exception('Missing ID token');
    }

    return AuthData(result.accessToken!, result.idToken!);
  }
}

AuthProvider getAuthProvider() {
  return NativeAuth();
}
