import 'package:digital_growth_charts_app/services/auth/auth_provider.dart';
import 'package:web/web.dart';

class WebAuth implements AuthProvider {
  @override
  Future<AuthData> login() async {
    window.open("/start-oauth.html");
    throw UnimplementedError('Use login_web() for web authentication');
  }
}

AuthProvider getAuthProvider() {
  return WebAuth();
}
