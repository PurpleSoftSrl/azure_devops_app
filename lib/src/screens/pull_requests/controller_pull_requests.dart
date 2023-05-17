part of pull_requests;

class _PullRequestsController with FilterMixin {
  factory _PullRequestsController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    return instance ??= _PullRequestsController._(apiService, storageService, project);
  }

  _PullRequestsController._(this.apiService, this.storageService, this.project);

  static _PullRequestsController? instance;

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final pullRequests = ValueNotifier<ApiResponse<List<PullRequest>?>?>(null);

  PullRequestState statusFilter = PullRequestState.all;

  final allProject = Project(
    id: '-1',
    name: 'All',
    description: '',
    url: '',
    state: '',
    revision: -1,
    visibility: '',
    lastUpdateTime: DateTime.now(),
  );

  late Project projectFilter = project ?? allProject;
  List<Project> projects = [];

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    projects = [allProject];

    projects.addAll(storageService.getChosenProjects());

    await _getData();
  }

  void goToPullRequestDetail(PullRequest pr) {
    AppRouter.goToPullRequestDetail(pr);
  }

  void filterByStatus(PullRequestState state) {
    pullRequests.value = null;
    statusFilter = state;
    _getData();
  }

  void filterByUser(GraphUser u) {
    pullRequests.value = null;
    userFilter = u;
    _getData();
  }

  void filterByProject(Project proj) {
    pullRequests.value = null;
    projectFilter = proj.name! == 'All' ? allProject : proj;
    _getData();
  }

  Future<void> _getData() async {
    final res = await apiService.getPullRequests(
      filter: statusFilter,
      creator: userFilter.displayName == 'All' ? null : userFilter,
      project: projectFilter.name == 'All' ? null : projectFilter,
    );
    pullRequests.value = res..data?.sort((a, b) => (b.creationDate).compareTo(a.creationDate));
  }

  void resetFilters() {
    pullRequests.value = null;
    projectFilter = allProject;
    statusFilter = PullRequestState.all;
    userFilter = userAll;

    init();
  }
}
