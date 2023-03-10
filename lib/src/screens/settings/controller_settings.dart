part of settings;

class _SettingsController {
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

    Share.share(appUrl);
  }

  Future<void> logout() async {
    final confirm = await AlertService.confirm(
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
    ScaffoldMessenger.of(AppRouter.rootNavigator!.context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cache cleared!'),
            Icon(DevOpsIcons.success),
          ],
        ),
        margin: EdgeInsets.fromLTRB(20, 0, 20, AppRouter.rootNavigator!.context.height - 180),
        behavior: SnackBarBehavior.floating,
      ),
    );

    AppRouter.goToChooseProjects(removeRoutes: false);
  }

  Future<void> setNewToken(String token) async {
    if (token.isEmpty) return;

    final res = await apiService.login(token);

    if (res == LoginStatus.failed || res == LoginStatus.unauthorized) {
      patTextFieldController.text = pat;
      return AlertService.error(
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
}
