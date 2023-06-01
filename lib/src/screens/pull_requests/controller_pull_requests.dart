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

  PullRequestState statusFilter = PullRequestState.all;

  void dispose() {
    instance = null;
    _instances.remove(project.hashCode);
  }

  Future<void> init() async {
    await _getData();
  }

  void goToPullRequestDetail(PullRequest pr) {
    AppRouter.goToPullRequestDetail(project: pr.repository.project.name, id: pr.pullRequestId);
  }

  void filterByStatus(PullRequestState state) {
    if (state == statusFilter) return;

    pullRequests.value = null;
    statusFilter = state;
    _getData();
  }

  void filterByUser(GraphUser u) {
    if (u.mailAddress == userFilter.mailAddress) return;

    pullRequests.value = null;
    userFilter = u;
    _getData();
  }

  void filterByProject(Project proj) {
    if (proj.id == projectFilter.id) return;

    pullRequests.value = null;
    projectFilter = proj.name! == projectAll.name ? projectAll : proj;
    _getData();
  }

  Future<void> _getData() async {
    final res = await apiService.getPullRequests(
      filter: statusFilter,
      creator: userFilter.displayName == userAll.displayName ? null : userFilter,
      project: projectFilter.name == projectAll.name ? null : projectFilter,
    );
    pullRequests.value = res..data?.sort((a, b) => (b.creationDate).compareTo(a.creationDate));
  }

  void resetFilters() {
    pullRequests.value = null;
    projectFilter = projectAll;
    statusFilter = PullRequestState.all;
    userFilter = userAll;

    init();
  }
}
