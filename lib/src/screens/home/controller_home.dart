part of home;

class _HomeController {
  factory _HomeController({required AzureApiService apiService}) {
    return instance ??= _HomeController._(apiService);
  }

  _HomeController._(this.apiService);

  static _HomeController? instance;

  final AzureApiService apiService;

  final projects = ValueNotifier<ApiResponse<List<Project>>?>(null);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final allProjectsRes = await apiService.getProjects();
    final allProjects = allProjectsRes.data ?? [];

    final alreadyChosenProjects = StorageServiceCore().getChosenProjects();

    final existentProjects = alreadyChosenProjects.where((p) => allProjects.map((e) => e.id!).contains(p.id));
    final sortedProjects = existentProjects.toList()..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!));

    projects.value = ApiResponse.ok(sortedProjects);

    StorageServiceCore().setChosenProjects(existentProjects);

    _configureSentryScope();

    await _maybeRequestReview();
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
    final numberOfSessions = StorageServiceCore().numberOfSessions;
    if (numberOfSessions == 5) {
      final inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    }

    StorageServiceCore().increaseNumberOfSessions();
  }
}
