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

    _configureSentryScope();

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

  /// Shows review dialog only the 5th time the app is opened.
  Future<void> _maybeRequestReview() async {
    final numberOfSessions = storageService.numberOfSessions;
    if (numberOfSessions == 5) {
      final inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
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
