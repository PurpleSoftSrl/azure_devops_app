part of settings;

class _SettingsController with ShareMixin {
  factory _SettingsController({required AzureApiService apiService}) {
    return instance ??= _SettingsController._(apiService);
  }

  _SettingsController._(this.apiService);

  static _SettingsController? instance;

  final AzureApiService apiService;

  late String gitUsername = apiService.user!.emailAddress!;
  late String pat = apiService.accessToken;

  final appVersion = ValueNotifier<String>('');

  late final patTextFieldController = TextEditingController(text: pat);

  final isEditing = ValueNotifier(false);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
  }

  void shareApp() {
    final appUrl = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=io.purplesoft.azuredevops'
        : 'https://apps.apple.com/app/apple-store/id1666994628?pt=120276127&ct=app&mt=8';

    shareUrl(appUrl);
  }

  Future<void> logout() async {
    final confirm = await OverlayService.confirm(
      'Do you really want to logout?',
      description: 'You will have to insert your PAT again',
    );
    if (!confirm) return;

    await apiService.logout();
    unawaited(AppRouter.goToLogin());
  }

  void seeChosenProjects() {
    AppRouter.goToChooseProjects(removeRoutes: false);
  }

  void changeThemeMode(String mode) {
    PurpleTheme.of(AppRouter.rootNavigator!.context).changeTheme(mode);
    StorageServiceCore().setThemeMode(mode);
  }

  void clearLocalStorage() {
    StorageServiceCore().clearNoToken();

    OverlayService.snackbar('Cache cleared!');

    AppRouter.goToChooseProjects(removeRoutes: false);
  }

  Future<void> setNewToken(String token) async {
    if (token.isEmpty) return;

    final res = await apiService.login(token);

    if (res == LoginStatus.failed || res == LoginStatus.unauthorized) {
      patTextFieldController.text = pat;
      return OverlayService.error(
        'Login failed',
        description: 'Check that the Personal Access Token is valid and retry',
      );
    }

    StorageServiceCore().clearNoToken();
    unawaited(AppRouter.goToSplash());
  }

  void toggleIsEditingToken() {
    isEditing.value = !isEditing.value;

    if (!isEditing.value && patTextFieldController.text != pat) {
      setNewToken(patTextFieldController.text);
    }
  }

  void openPurplesoftWebsite(FollowLink? link) {
    if (kReleaseMode) Sentry.captureMessage('Open Purplesoft website');

    link?.call();
  }

  void openAppStore() {
    InAppReview.instance.openStoreListing(appStoreId: '1666994628');
  }
}
