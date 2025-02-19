import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:msal_auth/msal_auth.dart';

class MsalService with AppLogger {
  factory MsalService() {
    return instance ??= MsalService._();
  }

  MsalService._();

  static MsalService? instance;

  static const _scopes = ['499b84ac-1321-427f-aa17-267ca6975798/user_impersonation'];

  SingleAccountPca? _pca;

  var _isLoggedIn = false;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    setTag('MsalService');

    const msalClientId = String.fromEnvironment('MSAL_CLIENT_ID');
    const msalRedirectUri = String.fromEnvironment('MSAL_REDIRECT_URI');

    _pca = await SingleAccountPca.create(
      clientId: msalClientId,
      androidConfig: AndroidConfig(configFilePath: 'assets/msal_config.json', redirectUri: msalRedirectUri),
      appleConfig: AppleConfig(),
    );
  }

  Future<void> logout() async {
    if (!_isLoggedIn) return;

    try {
      if (_pca == null) await init();

      await _pca!.signOut();
    } on MsalUserCancelException catch (_) {
      // ignore
    } on MsalException catch (e, s) {
      logError(e, s);
    }
  }

  Future<String?> login() async {
    try {
      if (_pca == null) await init();

      final token = await _pca!.acquireToken(scopes: _scopes, prompt: Prompt.selectAccount);
      _isLoggedIn = true;
      return token.accessToken;
    } on MsalUserCancelException catch (_) {
      return null;
    } on MsalException catch (e, s) {
      logError(e, s);
      return null;
    }
  }

  Future<String?> loginSilently() async {
    try {
      if (_pca == null) await init();

      final token = await _pca!.acquireTokenSilent(scopes: _scopes);
      _isLoggedIn = true;
      return token.accessToken;
    } on MsalException catch (e, s) {
      logError(e, s);
      return null;
    }
  }
}
