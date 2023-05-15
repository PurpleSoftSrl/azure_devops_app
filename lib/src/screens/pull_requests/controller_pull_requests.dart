part of pull_requests;

class _PullRequestsController {
  factory _PullRequestsController({required AzureApiService apiService, required StorageService storageService}) {
    return instance ??= _PullRequestsController._(apiService, storageService);
  }

  _PullRequestsController._(this.apiService, this.storageService);

  static _PullRequestsController? instance;

  final AzureApiService apiService;

  final StorageService storageService;

  final pullRequests = ValueNotifier<ApiResponse<List<PullRequest>?>?>(null);

  PullRequestState statusFilter = PullRequestState.all;

  final _userAll = GraphUser(
    subjectKind: '',
    domain: '',
    principalName: '',
    mailAddress: '',
    origin: '',
    originId: '',
    displayName: 'All',
    links: null,
    url: '',
    descriptor: '',
    metaType: '',
    directoryAlias: '',
  );

  late GraphUser userFilter = _userAll;
  List<GraphUser> users = [];

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

  late Project projectFilter = allProject;
  List<Project> projects = [];

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    projects = [allProject];

    users = apiService.allUsers
        .where((u) => u.domain != 'Build' && u.domain != 'AgentPool' && u.domain != 'LOCAL AUTHORITY')
        .sorted((a, b) => a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()))
        .toList();

    users.insert(0, _userAll);

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
    userFilter = _userAll;

    init();
  }
}
