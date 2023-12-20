part of pull_requests;

class _PullRequestsController with FilterMixin {
  factory _PullRequestsController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    // handle page already in memory with a different project filter
    if (_instances[project.hashCode] != null) {
      return _instances[project.hashCode]!;
    }

    if (instance != null && project?.id != instance!.project?.id) {
      instance = null;
    }

    instance ??= _PullRequestsController._(apiService, storageService, project);
    return _instances.putIfAbsent(project.hashCode, () => instance!);
  }

  _PullRequestsController._(this.apiService, this.storageService, this.project) {
    if (project != null) projectsFilter = {project!};
  }

  static _PullRequestsController? instance;
  static final Map<int, _PullRequestsController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

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

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    _fillSavedFilters();

    await _getData();
  }

  void _fillSavedFilters() {
    final savedFilters = filtersService.getPullRequestsSavedFilters();

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

    filtersService.savePullRequestsStatusFilter(status.name);
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    pullRequests.value = null;
    usersFilter = users;
    _getData();

    filtersService.savePullRequestsOpenedByFilter(users.map((p) => p.mailAddress!).toSet());
  }

  void filterByReviewers(Set<GraphUser> users) {
    if (users == reviewersFilter) return;

    pullRequests.value = null;
    reviewersFilter = users;
    _getData();

    filtersService.savePullRequestsAssignedToFilter(users.map((p) => p.mailAddress!).toSet());
  }

  void filterByProjects(Set<Project> projects) {
    if (projects == projectsFilter) return;

    pullRequests.value = null;
    projectsFilter = projects;
    _getData();

    filtersService.savePullRequestsProjectsFilter(projects.map((p) => p.name!).toSet());
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

    filtersService.resetPullRequestsFilters();

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
}
