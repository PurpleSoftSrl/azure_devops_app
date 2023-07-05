part of home;

class _HomeController with AppLogger {
  factory _HomeController({required AzureApiService apiService, required StorageService storageService}) {
    return instance ??= _HomeController._(apiService, storageService);
  }

  _HomeController._(this.apiService, this.storageService);

  static _HomeController? instance;

  final AzureApiService apiService;
  final StorageService storageService;

  final projects = ValueNotifier<ApiResponse<List<Project>>?>(null);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final allProjectsRes = await apiService.getProjects();
    final allProjects = allProjectsRes.data ?? [];

    // avoid resetting projects if response is error (and thus contains zero projects)
    if (allProjectsRes.isError) {
      projects.value = allProjectsRes;
      return;
    }

    final alreadyChosenProjects = storageService.getChosenProjects();

    final existentProjects = alreadyChosenProjects.where((p) => allProjects.map((e) => e.id!).contains(p.id));
    final sortedProjects = existentProjects.toList()..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!));

    projects.value = ApiResponse.ok(sortedProjects);

    storageService.setChosenProjects(existentProjects);

    _configureSentryAndFirebase();

    await _maybeRequestReview();

    _logSession();
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

  void goToProjectDetail(Project p) {
    AppRouter.goToProjectDetail(p.name!);
  }

  void _configureSentryAndFirebase() {
    final userId = apiService.user?.id ?? 'uknown-id';
    final email = apiService.user?.emailAddress ?? 'unknown-user';
    final org = apiService.organization;

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
    final sessionCount = storageService.numberOfSessions;
    if (sessionCount == 5) {
      final inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        logAnalytics('app_review_popup', {});
      }
    }

    storageService.increaseNumberOfSessions();
  }

  void _logSession() {
    Timer(Duration(seconds: 5), () {
      if (apiService.user != null) logInfo('5 seconds session');
    });
  }
}
