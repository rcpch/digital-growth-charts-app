import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

    await storage.write(key: 'id_token', value: authData.idToken);
    await storage.write(key: 'refresh_token', value: authData.refreshToken);

    return authData;
  }
}
