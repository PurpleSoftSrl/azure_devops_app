part of pull_requests;

class _PullRequestsController with FilterMixin {
  factory _PullRequestsController({
    required AzureApiService apiService,
    required StorageService storageService,
    PullRequestArgs? args,
  }) {
    // handle page already in memory with a different project filter
    if (_instances[args.hashCode] != null) {
      return _instances[args.hashCode]!;
    }

    if (instance != null && args != instance!.args) {
      instance = null;
    }

    instance ??= _PullRequestsController._(apiService, storageService, args);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _PullRequestsController._(this.apiService, this.storageService, this.args) {
    if (args?.project != null) projectsFilter = {args!.project!};
  }

  static _PullRequestsController? instance;
  static final Map<int, _PullRequestsController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final PullRequestArgs? args;

  final pullRequests = ValueNotifier<ApiResponse<List<PullRequest>?>?>(null);
  List<PullRequest> allPullRequests = [];

  PullRequestStatus statusFilter = PullRequestStatus.all;

  Set<GraphUser> reviewersFilter = {};

  final isSearching = ValueNotifier<bool>(false);
  String? _currentSearchQuery;

  late final filtersService = FiltersService(
    storageService: storageService,
    organization: apiService.organization,
  );

  /// Read/write filters from local storage only if user is not coming from project page
  bool get shouldPersistFilters => args?.project == null && !hasShortcut;

  bool get hasShortcut => args?.shortcut != null;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    if (shouldPersistFilters) {
      _fillSavedFilters();
    } else if (hasShortcut) {
      _fillShortcutFilters();
    }

    await _getData();
  }

  void _fillSavedFilters() {
    final savedFilters = filtersService.getPullRequestsSavedFilters();
    _fillFilters(savedFilters);
  }

  void _fillShortcutFilters() {
    final savedFilters = filtersService.getPullRequestsShortcut(args!.shortcut!.label);
    _fillFilters(savedFilters);
  }

  void _fillFilters(PullRequestsFilters savedFilters) {
    if (savedFilters.projects.isNotEmpty) {
      projectsFilter = getProjects(storageService).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.status.isNotEmpty) {
      statusFilter = PullRequestStatus.fromString(savedFilters.status.first);
    }

    if (savedFilters.openedBy.isNotEmpty) {
      usersFilter = getSortedUsers(apiService).where((p) => savedFilters.openedBy.contains(p.mailAddress)).toSet();
    }

    if (savedFilters.assignedTo.isNotEmpty) {
      reviewersFilter =
          getSortedUsers(apiService).where((p) => savedFilters.assignedTo.contains(p.mailAddress)).toSet();
    }
  }

  Future<void> goToPullRequestDetail(PullRequest pr) async {
    await AppRouter.goToPullRequestDetail(
      project: pr.repository.project.name,
      repository: pr.repository.id,
      id: pr.pullRequestId,
    );
    await init();
  }

  void filterByStatus(PullRequestStatus status) {
    if (status == statusFilter) return;

    pullRequests.value = null;
    statusFilter = status;
    _getData();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsStatusFilter(status.name);
    }
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    pullRequests.value = null;
    usersFilter = users;
    _getData();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsOpenedByFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void filterByReviewers(Set<GraphUser> users) {
    if (users == reviewersFilter) return;

    pullRequests.value = null;
    reviewersFilter = users;
    _getData();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsAssignedToFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void filterByProjects(Set<Project> projects) {
    if (projects == projectsFilter) return;

    pullRequests.value = null;
    projectsFilter = projects;
    _getData();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsProjectsFilter(projects.map((p) => p.name!).toSet());
    }
  }

  Future<void> _getData() async {
    final res = await apiService.getPullRequests(
      status: statusFilter,
      creators: isDefaultUsersFilter ? null : usersFilter,
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      reviewers: reviewersFilter.isEmpty ? null : reviewersFilter,
    );

    pullRequests.value = res..data?.sort((a, b) => (b.creationDate).compareTo(a.creationDate));
    allPullRequests = pullRequests.value?.data ?? [];

    if (_currentSearchQuery != null) {
      searchPullRequests(_currentSearchQuery!);
    }
  }

  void resetFilters() {
    pullRequests.value = null;
    projectsFilter.clear();
    statusFilter = PullRequestStatus.all;
    usersFilter.clear();
    reviewersFilter.clear();

    if (shouldPersistFilters) {
      filtersService.resetPullRequestsFilters();
    }

    init();
  }

  void searchPullRequests(String query) {
    _currentSearchQuery = query.trim().toLowerCase();

    final matchedItems = allPullRequests
        .where(
          (i) =>
              i.pullRequestId.toString().contains(_currentSearchQuery!) ||
              i.title.toLowerCase().contains(_currentSearchQuery!),
        )
        .toList();

    pullRequests.value = pullRequests.value?.copyWith(data: matchedItems);
  }

  void resetSearch() {
    searchPullRequests('');
    isSearching.value = false;
  }

  Future<void> saveFilters() async {
    final shortcutLabel = await OverlayService.formBottomsheet(title: 'Choose a name', label: 'Name');
    if (shortcutLabel == null) return;

    final res = filtersService.savePullRequestsShortcut(shortcutLabel, {
      if (!isDefaultProjectsFilter) PullRequestsFilters.projectsKey: projectsFilter.map((p) => p.name!).toSet(),
      if (statusFilter != PullRequestStatus.all) PullRequestsFilters.statusKey: {statusFilter.name},
      if (!isDefaultUsersFilter) PullRequestsFilters.openedByKey: usersFilter.map((u) => u.mailAddress!).toSet(),
      if (reviewersFilter.isNotEmpty)
        PullRequestsFilters.assignedToKey: reviewersFilter.map((u) => u.mailAddress!).toSet(),
    });

    if (!res.result) {
      OverlayService.snackbar(res.message, isError: true);
    }
  }
}
