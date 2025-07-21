part of splash;

class _SplashController {
  _SplashController._(this.api);

  final AzureApiService api;

  static const _splashMinDuration = Duration(milliseconds: 1200);

  late LoginStatus _isLogged;

  String _errorMessage = 'Generic error';

  Future<void> init() async {
    final token = StorageServiceCore().getToken();

    // wait at least [_splashMinDuration] before navigating
    await Future.wait([
      Future<void>.delayed(_splashMinDuration),
      _login(token),
    ]);

    await _init(token);
  }

  Future<void> _login(String token) async {
    try {
      _isLogged = await api.login(token);
    } on SocketException catch (_) {
      _isLogged = LoginStatus.failed;
      _errorMessage = 'Check your internet connection';
    } catch (e) {
      _isLogged = LoginStatus.failed;
    }
  }

  Future<void> _init(String token) async {
    if (token.isEmpty) {
      unawaited(AppRouter.goToLogin());
      return;
    }

    if (_isLogged == LoginStatus.unauthorized) {
      // token is expired
      await OverlayService.error('Error', description: 'Token expired');
      await api.logout();
      await MsalService().logout();

      // Rebuild app to reset dependencies. This is needed to fix user null error after logout and login
      rebuildApp();

      unawaited(AppRouter.goToLogin());
      return;
    }

    if (_isLogged == LoginStatus.failed) {
      unawaited(AppRouter.goToError(description: _errorMessage));
      return;
    }

    if (_isLogged == LoginStatus.projectsNotSet || _isLogged == LoginStatus.orgNotSet) {
      unawaited(AppRouter.goToChooseProjects());
      return;
    }

    unawaited(AppRouter.goToTabs());
  }
}
