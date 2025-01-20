part of settings;

class _SettingsController with ShareMixin, AppLogger {
  _SettingsController._(this.apiService, this.storageService);

  final AzureApiService apiService;
  final StorageService storageService;

  late String gitUsername = apiService.user!.emailAddress!;

  String appVersion = '';

  final organizations = ValueNotifier<ApiResponse<List<Organization>>?>(null);

  bool get hasMultiOrgs => (organizations.value?.data?.length ?? 0) > 1;

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    appVersion = info.version;

    final orgs = await apiService.getOrganizations();
    // copyWith is needed to make page visible even if getOrganizations returns 401
    organizations.value = orgs.copyWith(isError: false, data: []);
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

    await apiService.logout();
    await MsalService().logout();

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
    storageService.setThemeMode(mode);
  }

  void clearLocalStorage() {
    storageService.clearNoToken();

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

  Future<void> switchOrganization() async {
    final selectedOrg = await _selectOrganization(organizations.value!.data!);
    if (selectedOrg == null) return;

    apiService.switchOrganization(selectedOrg.accountName!);
    unawaited(AppRouter.goToSplash());
  }

  Future<Organization?> _selectOrganization(List<Organization> organizations) async {
    final currentOrg = storageService.getOrganization();

    Organization? selectedOrg;

    await OverlayService.bottomsheet(
      title: 'Select your organization',
      isScrollControlled: true,
      heightPercentage: .7,
      builder: (context) => ListView(
        children: organizations
            .map(
              (org) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: LoadingButton(
                  onPressed: () {
                    selectedOrg = org;
                    AppRouter.popRoute();
                  },
                  text: org.accountName == currentOrg ? '${org.accountName!} (current)' : org.accountName!,
                ),
              ),
            )
            .toList(),
      ),
    );

    if (selectedOrg?.accountName == currentOrg) return null;

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
}

class _H2PaddingBuilder extends MarkdownPaddingBuilder {
  @override
  EdgeInsets getPadding() => const EdgeInsets.only(top: 16);
}
