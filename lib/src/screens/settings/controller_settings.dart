part of settings;

class _SettingsController with ShareMixin, AppLogger {
  _SettingsController._(this.api, this.storage);

  final AzureApiService api;
  final StorageService storage;

  late String gitUsername = api.user!.emailAddress!;

  String appVersion = '';

  final directories = ValueNotifier<ApiResponse<List<UserTenant>>?>(null);

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    appVersion = info.version;

    final orgs = await api.getDirectories();
    // copyWith is needed to make page visible even if getDirectories returns 401
    directories.value = orgs.copyWith(isError: false, data: orgs.data ?? []);
  }

  void shareApp() {
    final appUrl = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=io.purplesoft.azuredevops'
        : 'https://apps.apple.com/app/apple-store/id1666994628?pt=120276127&ct=app&mt=8';

    shareUrl(appUrl);
  }

  Future<void> logout() async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to logout?',
    );
    if (!confirm) return;

    await api.logout();
    await MsalService().logout();

    // Rebuild app to reset dependencies. This is needed to fix user null error after logout and login
    rebuildApp();

    unawaited(AppRouter.goToLogin());
  }

  void goToChooseSubscription() {
    AppRouter.goToChooseSubscription();
  }

  void seeChosenProjects() {
    AppRouter.goToChooseProjects(removeRoutes: false);
  }

  void changeThemeMode(String mode) {
    PurpleTheme.of(AppRouter.rootNavigator!.context).changeTheme(mode);
    storage.setThemeMode(mode);
  }

  void clearLocalStorage() {
    storage.clearNoToken();

    OverlayService.snackbar('Cache cleared!');

    AppRouter.goToChooseProjects(removeRoutes: false);
  }

  void openPurplesoftWebsite(FollowLink? link) {
    logInfo('Open Purplesoft website');

    link?.call();
  }

  void openAppStore() {
    InAppReview.instance.openStoreListing(appStoreId: '1666994628');
  }

  Future<void> chooseDirectory() async {
    await OverlayService.bottomsheet(
      title: 'Switch directory',
      isScrollControlled: true,
      heightPercentage: .6,
      builder: (context) => _SwitchDirectoryWidget(
        directories: directories.value?.data ?? [],
        onSwitch: _switchOrganization,
      ),
    );
  }

  Future<void> _switchOrganization(UserTenant tenant) async {
    try {
      // Logout to avoid cached account errors
      await MsalService().logout();
    } catch (e) {
      // ignore
    }

    final loginRes = await MsalService().login(authority: 'https://login.microsoftonline.com/${tenant.id}');

    if (loginRes != null) unawaited(_loginAndNavigate(loginRes));
  }

  Future<void> chooseAccount() async {
    try {
      // Logout to avoid cached account errors
      await MsalService().logout();
    } catch (e) {
      // ignore
    }

    final loginRes = await MsalService().login();

    if (loginRes != null) unawaited(_loginAndNavigate(loginRes));
  }

  Future<void> _loginAndNavigate(LoginResponse loginResponse) async {
    storage
      ..setOrganization('')
      ..setTenantId(loginResponse.tenantId);

    final isLogged = await api.login(loginResponse.accessToken);

    final isFailed = [LoginStatus.failed, LoginStatus.unauthorized].contains(isLogged);

    logAnalytics('switch_directory_${isFailed ? 'failed' : 'success'}', {});

    if (isLogged == LoginStatus.failed) {
      return _switchDirectoryErrorAlert();
    }

    final orgsRes = await api.getOrganizations();

    if (orgsRes.data?.isEmpty ?? true) {
      return _switchDirectoryErrorAlert();
    }

    final directoryProjects = storage.getTenantChosenProjects(loginResponse.tenantId);

    if (directoryProjects.isNotEmpty) {
      await _chooseOrg(orgsRes.data!);
      storage.setChosenProjects(directoryProjects);
      return AppRouter.goToTabs();
    }

    await AppRouter.goToChooseProjects();
  }

  Future<void> _switchDirectoryErrorAlert() {
    return OverlayService.error(
      'Error switching directory',
      description:
          'Check that you have access to this organization and that the organization has at least one project.',
    );
  }

  Future<void> _chooseOrg(List<Organization> orgs) async {
    if (orgs.length < 2) {
      await api.setOrganization(orgs.first.accountName!);
      return;
    }

    final selectedOrg = await _selectOrganization(orgs);
    if (selectedOrg == null) return;

    await api.setOrganization(selectedOrg.accountName!);
  }

  Future<Organization?> _selectOrganization(List<Organization> orgs) async {
    Organization? selectedOrg;

    await OverlayService.bottomsheet(
      isDismissible: false,
      title: 'Select your organization',
      isScrollControlled: true,
      heightPercentage: .7,
      builder: (context) => ListView(
        children: [
          ...orgs.map(
            (u) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: LoadingButton(
                onPressed: () {
                  selectedOrg = u;
                  AppRouter.popRoute();
                },
                text: u.accountName!,
              ),
            ),
          ),
        ],
      ),
    );
    return selectedOrg;
  }

  Future<void> showChangelog() async {
    final str = await rootBundle.loadString('CHANGELOG.md');

    await OverlayService.bottomsheet(
      title: 'CHANGELOG',
      isScrollControlled: true,
      heightPercentage: .9,
      builder: (context) => SingleChildScrollView(
        child: AppMarkdownWidget(
          data: str,
          shrinkWrap: false,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(p: context.textTheme.titleSmall),
          paddingBuilders: {'h2': _H2PaddingBuilder()},
        ),
      ),
    );
  }

  void openPrivacyPolicy() {
    launchUrlString('https://www.iubenda.com/privacy-policy/92670429/legal');
  }

  void openTermsAndConditions() {
    launchUrlString('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
  }
}

class _H2PaddingBuilder extends MarkdownPaddingBuilder {
  @override
  EdgeInsets getPadding() => const EdgeInsets.only(top: 16);
}
