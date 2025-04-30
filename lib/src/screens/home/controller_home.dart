part of home;

class _HomeController with AppLogger {
  _HomeController._(this.api, this.storage, this.purchase);

  final AzureApiService api;
  final StorageService storage;
  final PurchaseService purchase;

  final projects = ValueNotifier<ApiResponse<List<Project>>?>(null);
  List<Project> allProjects = [];

  final isSearchingProjects = ValueNotifier<bool>(false);

  int _projectsCount = 0;
  bool get hasManyProjects => _projectsCount > 10;

  late final filtersService = FiltersService(
    storage: storage,
    organization: api.organization,
  );

  List<SavedShortcut> shortcuts = [];

  final visibilityKey = GlobalKey();

  Future<void> init() async {
    final allProjectsRes = await api.getProjects();
    allProjects = allProjectsRes.data ?? [];

    await purchase.init(
      userId: api.user?.emailAddress,
      userName: api.user?.displayName,
    );

    // avoid resetting projects if response is error (and thus contains zero projects)
    if (allProjectsRes.isError) {
      projects.value = allProjectsRes;
      return;
    }

    final alreadyChosenProjects = storage.getChosenProjects();

    final existentProjects = alreadyChosenProjects.where((p) => allProjects.map((e) => e.id!).contains(p.id));
    final sortedProjects = existentProjects.toList()..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!));

    _projectsCount = existentProjects.length;

    _hideSearchField();

    _getShortcuts();

    projects.value = ApiResponse.ok(sortedProjects);

    storage.setChosenProjects(existentProjects);

    _configureSentryAndFirebase();

    await _maybeRequestReview();

    _logSession();

    final hasSubscription = await purchase.checkSubscription();
    if (!hasSubscription) {
      _maybeShowSubscriptionBottomsheet();
    }

    if (Platform.isAndroid) {
      await ShareIntentService().maybeHandleSharedUrl();
    }
  }

  Future<void> goToCommits() async {
    await AppRouter.goToCommits();
  }

  Future<void> goToPipelines() async {
    await AppRouter.goToPipelines();
  }

  void goToWorkItems() {
    AppRouter.goToWorkItems();
  }

  void goToPullRequests() {
    AppRouter.goToPullRequests();
  }

  void goToChooseProjects() {
    AppRouter.goToChooseProjects();
  }

  Future<void> goToProjectDetail(Project p) async {
    await AppRouter.goToProjectDetail(p.name!);
    await init();
  }

  void goToListPage(SavedShortcut shortcut) {
    switch (shortcut.area) {
      case FilterAreas.commits:
        AppRouter.goToCommits(args: (shortcut: shortcut, project: null, author: null, repository: null));
      case FilterAreas.pipelines:
        AppRouter.goToPipelines(args: (definition: null, project: null, shortcut: shortcut));
      case FilterAreas.workItems:
        AppRouter.goToWorkItems(args: (project: null, shortcut: shortcut, savedQuery: null));
      case FilterAreas.pullRequests:
        AppRouter.goToPullRequests(args: (project: null, shortcut: shortcut));
    }
  }

  void _configureSentryAndFirebase() {
    final userId = api.user?.id ?? 'uknown-id';
    final email = api.user?.emailAddress ?? 'unknown-user';
    final org = api.organization;

    Sentry.configureScope((sc) async {
      await sc.setUser(SentryUser(id: userId, email: email));
      await sc.setTag('org', org);
    });

    if (useFirebase) {
      FirebaseAnalytics.instance.setUserId(id: email);
      FirebaseAnalytics.instance.setUserProperty(name: 'email', value: email);
      FirebaseAnalytics.instance.setUserProperty(name: 'org', value: org);
    }
  }

  /// Shows review dialog only the 5th time the app is opened.
  Future<void> _maybeRequestReview() async {
    final sessionCount = storage.numberOfSessions;
    if (sessionCount == 5) {
      final inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        logAnalytics('app_review_popup', {});
      }
    }

    storage.increaseNumberOfSessions();
  }

  void _logSession() {
    Timer(Duration(seconds: 5), () {
      if (api.user != null) logInfo('5 seconds session');
    });
  }

  void searchProjects(String query) {
    final trimmedQuery = query.trim().toLowerCase();

    final matchedProjects = allProjects.where((p) => p.name.toString().toLowerCase().contains(trimmedQuery)).toList();

    projects.value = projects.value?.copyWith(data: matchedProjects);
  }

  void resetSearch() {
    searchProjects('');
    _hideSearchField();
  }

  void showSearchField() {
    isSearchingProjects.value = true;
  }

  void _hideSearchField() {
    isSearchingProjects.value = false;
  }

  void visibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0) {
      _getShortcuts();
    }
  }

  void _getShortcuts() {
    shortcuts = filtersService.getOrganizationShortcuts();

    if (projects.value?.data == null) return;
    projects.value = ApiResponse.ok(projects.value!.data);
  }

  void showShortcut(SavedShortcut shortcut) {
    OverlayService.bottomsheet(
      title: shortcut.label,
      isScrollControlled: true,
      builder: (context) => ListView(
        children: shortcut.filters
            .map(
              (f) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.attribute.titleCase,
                    style: context.textTheme.bodyMedium,
                  ),
                  ...f.filters.map(
                    (f2) => Row(
                      children: [
                        CircleAvatar(
                          radius: 2,
                          backgroundColor: context.themeExtension.onBackground,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          f2,
                          style: context.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> renameShortcut(SavedShortcut shortcut) async {
    final shortcutLabel = await OverlayService.formBottomsheet(
      title: 'Rename shortcut',
      label: 'Name',
      initialValue: shortcut.label,
    );
    if (shortcutLabel == null) return;

    filtersService.renameShortcut(shortcut, label: shortcutLabel);

    _getShortcuts();
  }

  Future<void> deleteShortcut(SavedShortcut shortcut) async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: "Do you really want to delete '${shortcut.label}'?",
    );
    if (!confirm) return;

    filtersService.deleteShortcut(shortcut);

    _getShortcuts();
  }

  void _maybeShowSubscriptionBottomsheet() {
    if (storage.hasSeenSubscriptionAddedBottomsheet) return;

    // ignore: unawaited_futures
    OverlayService.bottomsheet(
      title: 'Hi there!',
      isDismissible: false,
      isScrollControlled: true,
      heightPercentage: .9,
      builder: (_) => _SubscriptionAddedBottomsheet(
        onRemoveAds: () {
          AppRouter.popRoute();
          _goToChooseSubscription();
        },
        onSkip: AppRouter.popRoute,
      ),
    );

    storage.setHasSeenSubscriptionAddedBottomsheet();
  }

  void _goToChooseSubscription() {
    AppRouter.goToChooseSubscription();
  }
}
