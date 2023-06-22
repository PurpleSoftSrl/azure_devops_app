part of project_detail;

class _ProjectDetailController {
  factory _ProjectDetailController({required AzureApiService apiService, required String projectName}) {
    // handle page already in memory with a different project
    if (_instances[projectName] != null) {
      return _instances[projectName]!;
    }

    if (instance != null && instance!.projectName != projectName) {
      instance = _ProjectDetailController._(apiService, projectName);
    }
    instance ??= _ProjectDetailController._(apiService, projectName);
    return _instances.putIfAbsent(projectName, () => instance!);
  }

  _ProjectDetailController._(this.apiService, this.projectName);

  static _ProjectDetailController? instance;

  static final Map<String, _ProjectDetailController> _instances = {};

  final AzureApiService apiService;

  final String projectName;

  final project = ValueNotifier<ApiResponse<ProjectDetail?>?>(null);

  List<TeamMember> members = <TeamMember>[];
  List<GitRepository> repos = <GitRepository>[];
  List<LanguageBreakdown> languages = <LanguageBreakdown>[];

  Iterable<LanguageBreakdown> get meaningfulLanguages => languages
      .where((l) => l.languagePercentage != null && l.languagePercentage! > 1)
      .sortedBy<num>((l) => l.languagePercentage!)
      .reversed;

  void dispose() {
    instance = null;
    _instances.remove(projectName);
  }

  Future<void> init() async {
    final allRes = await Future.wait<ApiResponse>([
      _getLangs(),
      _getMembers(),
      _getRepos(),
    ]);

    final projectRes = await apiService.getProject(projectName: projectName);

    final isAllErrors = allRes.every((r) => r.isError);
    project.value = projectRes.copyWith(isError: isAllErrors, errorResponse: allRes.first.errorResponse);
  }

  void goToRepoDetail(GitRepository repo) {
    if (repo.defaultBranch == null) {
      OverlayService.error('Error', description: 'This repo seems empty.');
      return;
    }

    AppRouter.goToRepositoryDetail(
      RepoDetailArgs(projectName: projectName, repositoryName: repo.name!),
    );
  }

  void goToMemberDetail(TeamMember member) {
    AppRouter.goToMemberDetail(member.identity!.descriptor!);
  }

  Future<ApiResponse<List<LanguageBreakdown>>> _getLangs() async {
    final langs = await apiService.getProjectLanguages(projectName: projectName);
    languages = langs.data ?? [];
    return langs;
  }

  Future<ApiResponse<List<TeamMember>>> _getMembers() async {
    final membersRes = await apiService.getProjectTeams(projectId: projectName);
    members = membersRes.data ?? [];
    return membersRes;
  }

  Future<ApiResponse<List<GitRepository>>> _getRepos() async {
    final reposRes = await apiService.getProjectRepositories(projectName: projectName);
    repos = reposRes.data ?? [];
    return reposRes;
  }

  void goToCommits() {
    AppRouter.goToCommits(project: project.value?.data?.project);
  }

  void goToPipelines() {
    AppRouter.goToPipelines(project: project.value?.data?.project);
  }

  void goToWorkItems() {
    AppRouter.goToWorkItems(project: project.value?.data?.project);
  }

  void goToPullRequests() {
    AppRouter.goToPullRequests(project: project.value?.data?.project);
  }
}
