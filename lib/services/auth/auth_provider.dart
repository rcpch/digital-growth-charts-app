import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import "auth_stub.dart"
    if (dart.library.html) "web_auth.dart"
    if (dart.library.io) "native_auth.dart";

class AuthData {
  final String _accessToken;
  final String _idToken;

  AuthData(this._accessToken, this._idToken);

  String get accessToken => _accessToken;
  String get idToken => _idToken;

  String get email {
    // TODO MRB: verify the token. Very important even though the backend does it too.
    final jwt = JWT.decode(_idToken);
    return jwt.payload['email'] as String;
  }
}

abstract class AuthProvider {
  Future<AuthData> login();

  factory AuthProvider() => getAuthProvider();
}
