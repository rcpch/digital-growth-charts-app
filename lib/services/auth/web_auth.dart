import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:digital_growth_charts_app/services/auth/auth_provider.dart';
import 'package:web/web.dart';

class WebAuth implements AuthProvider {
  @override
  Future<AuthData> login() async {
    final Completer<AuthData> thunk = Completer<AuthData>();

    BroadcastChannel channel = BroadcastChannel(
      'uk.ac.rcpch.dgc-app-test.oauth-channel',
    );

    // TODO MRB: needs timeout and error handling
    void onMessage(MessageEvent event) {
      if (!event.data.isA<JSString>()) {
        thunk.completeError(Exception('Invalid message data type'));
        return;
      }

      final data = (event.data as JSString).toString();
      final Map<String, dynamic> tokenData = jsonDecode(data);

      final refreshToken = tokenData['refresh_token'] as String;
      final idToken = tokenData['id_token'] as String;

      // Clean up the listener
      channel.close();

      thunk.complete(AuthData(idToken, refreshToken));
    }

    channel.onmessage = onMessage.toJS;

    window.open("/oauth.html");

    return thunk.future;
  }
}

AuthProvider getAuthProvider() {
  return WebAuth();
}
