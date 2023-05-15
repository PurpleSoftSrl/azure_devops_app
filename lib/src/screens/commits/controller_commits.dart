part of commits;

class _CommitsController {
  factory _CommitsController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    return instance ??= _CommitsController._(apiService, storageService, project);
  }

  _CommitsController._(this.apiService, this.storageService, this.project);

  static _CommitsController? instance;

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final recentCommits = ValueNotifier<ApiResponse<List<Commit>?>?>(null);

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

  Future<void> _getData() async {
    final res = await apiService.getRecentCommits(
      project: projectFilter.name == 'All' ? null : projectFilter,
      author: userFilter.displayName == 'All' ? null : userFilter.mailAddress,
    );
    var commits = (res.data ?? [])..sort((a, b) => b.author!.date!.compareTo(a.author!.date!));

    commits = commits.take(100).toList();

    recentCommits.value = res.copyWith(data: commits);
  }

  Future<void> goToCommitDetail(Commit c) async {
    await AppRouter.goToCommitDetail(c);
  }

  void filterByProject(Project proj) {
    recentCommits.value = null;
    projectFilter = proj.name! == 'All' ? allProject : proj;
    _getData();
  }

  void filterByUser(GraphUser u) {
    recentCommits.value = null;
    userFilter = u;
    _getData();
  }

  void resetFilters() {
    recentCommits.value = null;
    projectFilter = allProject;
    userFilter = _userAll;
    init();
  }
}
