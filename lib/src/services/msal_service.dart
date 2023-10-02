import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:msal_flutter/msal_flutter.dart';

class MsalService with AppLogger {
  factory MsalService() {
    return instance ??= MsalService._();
  }

  MsalService._();

  static MsalService? instance;

  static const _scopes = ['499b84ac-1321-427f-aa17-267ca6975798/user_impersonation'];

  PublicClientApplication? _pca;

  var _isLoggedIn = false;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    const msalClientId = String.fromEnvironment('MSAL_CLIENT_ID');
    const msalRedirectUri = String.fromEnvironment('MSAL_REDIRECT_URI');

    _pca = await PublicClientApplication.createPublicClientApplication(
      msalClientId,
      redirectUri: msalRedirectUri,
    );
  }

  Future<void> logout() async {
    if (!_isLoggedIn) return;

    try {
      if (_pca == null) await init();

      await _pca!.logout(browserLogout: true);
    } catch (e, s) {
      logError('MSAL logout exception: $e', s);
    }
  }

  Future<String?> login() async {
    try {
      if (_pca == null) await init();

      final token = await _pca!.acquireToken(_scopes);
      _isLoggedIn = true;
      return token;
    } catch (e, s) {
      logError('MSAL login exception: $e', s);
      return null;
    }
  }

  Future<String?> loginSilently() async {
    try {
      if (_pca == null) await init();

      final token = await _pca!.acquireTokenSilent(_scopes);
      _isLoggedIn = true;
      return token;
    } catch (e, s) {
      logError('MSAL loginSilently exception: $e', s);
      return null;
    }
  }
}
