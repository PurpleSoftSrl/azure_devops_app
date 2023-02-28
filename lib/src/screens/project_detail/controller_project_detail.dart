part of project_detail;

class _ProjectDetailController {
  factory _ProjectDetailController({required AzureApiService apiService, required String projectName}) {
    // handle page already in memory with a different project
    if (_instances[projectName] != null) {
      return _instances[projectName]!;
    }

    if (instance != null && instance!.projectName != projectName) {
      instance = _ProjectDetailController._(apiService, projectName, forceRefresh: true);
    }
    instance ??= _ProjectDetailController._(apiService, projectName);
    return _instances.putIfAbsent(projectName, () => instance!);
  }

  _ProjectDetailController._(this.apiService, this.projectName, {bool forceRefresh = false}) {
    if (forceRefresh) init();
  }

  static _ProjectDetailController? instance;

  static final Map<String, _ProjectDetailController> _instances = {};

  final AzureApiService apiService;

  final String projectName;

  final project = ValueNotifier<ApiResponse<Project?>?>(null);

  List<TeamMember> members = <TeamMember>[];
  List<GitRepository> repos = <GitRepository>[];
  List<PullRequest> pullRequests = <PullRequest>[];
  List<LanguageBreakdown> languages = <LanguageBreakdown>[];

  final pipelines = ValueNotifier(<Pipeline>[]);

  static const _top = 10;

  final now = DateTime.now();
  late var _to = now;

  Iterable<LanguageBreakdown> get meaningfulLanguages => languages
      .where((l) => l.languagePercentage != null && l.languagePercentage! > 1)
      .sortedBy<num>((l) => l.languagePercentage!)
      .reversed;

  void dispose() {
    instance = null;
    _instances.remove(projectName);
  }

  Future<void> init() async {
    _to = DateTime.now();

    await Future.wait([
      _getLangs(),
      _getMembers(),
      _getRepos(),
      _getPrs(),
      _getPipelines(),
    ]);

    project.value = await apiService.getProject(projectName: projectName);
  }

  Future<bool> loadMore() async {
    if (pipelines.value.isEmpty) return false;

    // get least recent pipeline
    _to = pipelines.value.sortedBy((p) => p.queueTime!).first.queueTime!;

    // subtract one second to avoid duplicate pipeline
    _to = _to.subtract(Duration(seconds: 1));

    final nextDayData = await _getData();

    final resLength = nextDayData.data?.length ?? 0;

    if (resLength <= 0) {
      return false;
    }

    // sort by start date. Pipelines in progress go first, then queued pipelines, and finally all the completed pipelines.
    nextDayData.data?.sort(
      (a, b) {
        final statusOrder = a.status!.order.compareTo(b.status.order);
        return statusOrder != 0 ? statusOrder : (b.startTime ?? now).compareTo(a.startTime ?? now);
      },
    );

    pipelines.value = nextDayData.data!..insertAll(0, pipelines.value);

    return true;
  }

  Future<ApiResponse<List<Pipeline>>> _getData() async {
    return apiService.getProjectPipelines(projectName: projectName, top: _top, to: _to);
  }

  void goToRepoDetail(GitRepository repo) {
    if (repo.defaultBranch == null) {
      AlertService.error('Error', description: 'This repo seems empty.');
      return;
    }

    AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: projectName, repositoryName: repo.name!),
    );
  }

  void goToPipelineDetail(Pipeline build) {
    AppRouter.goToPipelineDetail(build);
  }

  void goToMemberDetail(TeamMember member) {
    AppRouter.goToMemberDetail(member.identity!.descriptor!);
  }

  void goToPullRequestDetail(PullRequest pr) {
    AppRouter.goToPullRequestDetail(pr);
  }

  Future<void> _getLangs() async {
    final langs = await apiService.getProjectLanguages(projectName: projectName);
    languages = langs.data ?? [];
  }

  Future<void> _getMembers() async {
    final membersRes = await apiService.getProjectTeams(projectId: projectName);
    members = membersRes.data ?? [];
  }

  Future<void> _getRepos() async {
    final reposRes = await apiService.getProjectRepositories(projectName: projectName);
    repos = reposRes.data ?? [];
  }

  Future<void> _getPrs() async {
    final pullRequestsRes = await apiService.getProjectPullRequests(projectName: projectName);
    pullRequests = pullRequestsRes.data ?? [];
  }

  Future<void> _getPipelines() async {
    final pipelinesRes = await _getData();

    // sort by start date. Pipelines in progress go first, then queued pipelines, and finally all the completed pipelines.
    pipelinesRes.data?.sort(
      (a, b) {
        final statusOrder = a.status!.order.compareTo(b.status.order);
        return statusOrder != 0 ? statusOrder : (b.startTime ?? now).compareTo(a.startTime ?? now);
      },
    );

    pipelines.value.addAll(pipelinesRes.data ?? []);
  }
}
