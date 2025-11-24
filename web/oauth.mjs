import * as oauth from 'https://cdn.jsdelivr.net/npm/oauth4webapi@3.8.2/+esm';

export async function fetchConfig() {
  const response = await fetch('/assets/.env');
  const envText = await response.text();

  const env = {};

  for (const line of envText.split('\n')) {
    const [uncommented] = line.split("#");

    if (!uncommented.trim()) continue;

    const [key, value] = uncommented.split('=');
    env[key.trim()] = value.trim();
  }

  return env;
}

export async function oauthStart(clientId, issuer) {
  const redirectUri = `${window.location.origin}/oauth.html`;

  const as = await oauth
    .discoveryRequest(issuer)
    .then((response) => oauth.processDiscoveryResponse(issuer, response));

  const codeChallengeMethod = 'S256'
  /**
   * The following MUST be generated for every redirect to the authorization_endpoint. You must store
   * the code_verifier and nonce in the end-user session such that it can be recovered as the user
   * gets redirected from the authorization server back to your application.
   */
  const codeVerifier = oauth.generateRandomCodeVerifier();
  const codeChallenge = await oauth.calculatePKCECodeChallenge(codeVerifier);

  const nonce = oauth.generateRandomNonce();

  sessionStorage.setItem('uk.ac.rcpch.dgc-app-test.code_verifier', codeVerifier);
  sessionStorage.setItem('uk.ac.rcpch.dgc-app-test.nonce', nonce);

  const authorizationUrl = new URL(as.authorization_endpoint);
  authorizationUrl.searchParams.set('client_id', clientId);
  authorizationUrl.searchParams.set('redirect_uri', redirectUri);
  authorizationUrl.searchParams.set('response_type', 'code');
  authorizationUrl.searchParams.set('scope', 'openid profile email');
  authorizationUrl.searchParams.set('code_challenge', codeChallenge);
  authorizationUrl.searchParams.set('code_challenge_method', codeChallengeMethod);
  authorizationUrl.searchParams.set('nonce', nonce);

  window.location.href = authorizationUrl.toString();
}

export async function oauthCallback(clientId, issuer) {
  const client = {
    client_id: clientId,
  };

  const redirectUri = `${window.location.origin}/oauth.html`;

  // End of prerequisites

  const as = await oauth
    .discoveryRequest(issuer)
    .then((response) => oauth.processDiscoveryResponse(issuer, response));

  const params = oauth.validateAuthResponse(as, client, new URL(window.location.href));

  const codeVerifier = sessionStorage.getItem('uk.ac.rcpch.dgc-app-test.code_verifier');
  const nonce = sessionStorage.getItem('uk.ac.rcpch.dgc-app-test.nonce');

  const response = await oauth.authorizationCodeGrantRequest(
    as,
    client,
    oauth.None(),
    params,
    redirectUri,
    codeVerifier,
  );

  const result = await oauth.processAuthorizationCodeResponse(as, client, response, {
    expectedNonce: nonce,
    requireIdToken: true,
  });

  const channel = new BroadcastChannel('uk.ac.rcpch.dgc-app-test.oauth-channel');
  channel.postMessage(JSON.stringify(result));

  window.close();
}