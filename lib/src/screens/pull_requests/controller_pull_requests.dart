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
      instance = _PullRequestsController._(apiService, storageService, project);
    }

    instance ??= _PullRequestsController._(apiService, storageService, project);
    return _instances.putIfAbsent(project.hashCode, () => instance!);
  }

  _PullRequestsController._(this.apiService, this.storageService, this.project) {
    projectFilter = project ?? projectAll;
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

  void dispose() {
    instance = null;
    _instances.remove(project.hashCode);
  }

  Future<void> init() async {
    await _getData();
  }

  Future<void> goToPullRequestDetail(PullRequest pr) async {
    await AppRouter.goToPullRequestDetail(
      project: pr.repository.project.name,
      repository: pr.repository.id,
      id: pr.pullRequestId,
    );
    await init();
  }

  void filterByStatus(PullRequestStatus state) {
    if (state == statusFilter) return;

    pullRequests.value = null;
    statusFilter = state;
    _getData();
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    pullRequests.value = null;
    usersFilter = users;
    _getData();
  }

  void filterByReviewers(Set<GraphUser> users) {
    if (users == reviewersFilter) return;

    pullRequests.value = null;
    reviewersFilter = users;
    _getData();
  }

  void filterByProjects(Set<Project> projects) {
    if (projects == projectsFilter) return;

    pullRequests.value = null;
    projectsFilter = projects;
    _getData();
  }

  Future<void> _getData() async {
    final res = await apiService.getPullRequests(
      status: statusFilter,
      creators: usersFilter.isEmpty ? null : usersFilter,
      projects: projectsFilter.isEmpty ? null : projectsFilter,
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
