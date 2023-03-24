part of splash;

class _SplashController {
  factory _SplashController({required AzureApiService apiService}) {
    return instance ??= _SplashController._(apiService);
  }

  _SplashController._(this.apiService);

  static _SplashController? instance;

  final AzureApiService apiService;

  static const _splashMinDuration = Duration(milliseconds: 1200);

  late LoginStatus _isLogged;

  String _errorMessage = 'Generic error';

  void dispose() {
    instance = null;
  }

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
      _isLogged = await apiService.login(token);
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
      await AlertService.error('Error', description: 'Token expired');
      await apiService.logout();
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

    _configureSentryScope();

    unawaited(AppRouter.goToTabs());
  }

  void _configureSentryScope() {
    Sentry.configureScope((sc) async {
      final user = apiService.user;
      await sc.setUser(
        SentryUser(
          id: user?.id ?? 'user-not-logged-id',
          email: user?.emailAddress ?? 'user-not-logged-email',
        ),
      );
      await sc.setTag('org', apiService.organization);
    });
  }
}
