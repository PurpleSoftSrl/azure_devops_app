part of project_detail;

class _ProjectDetailController {
  _ProjectDetailController._(this.apiService, this.projectName);

  final AzureApiService apiService;

  final String projectName;

  final project = ValueNotifier<ApiResponse<ProjectDetail?>?>(null);

  List<TeamWithMembers> teamsWithMembers = <TeamWithMembers>[];
  List<GitRepository> repos = <GitRepository>[];
  List<LanguageBreakdown> languages = <LanguageBreakdown>[];

  Iterable<LanguageBreakdown> get meaningfulLanguages => languages
      .where((l) => l.languagePercentage != null && l.languagePercentage! > 1)
      .sortedBy<num>((l) => l.languagePercentage!)
      .reversed;

  Future<void> init() async {
    final allRes = await Future.wait<ApiResponse>([
      _getLangs(),
      _getTeams(),
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

  Future<ApiResponse<List<TeamWithMembers>>> _getTeams() async {
    final membersRes = await apiService.getProjectTeams(projectId: projectName);
    teamsWithMembers = membersRes.data ?? [];
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
    AppRouter.goToPipelines(args: (project: project.value?.data?.project, definition: null, shortcut: null));
  }

  void goToWorkItems() {
    AppRouter.goToWorkItems(args: (project: project.value?.data?.project, shortcut: null));
  }

  void goToPullRequests() {
    AppRouter.goToPullRequests(args: (project: project.value?.data?.project, shortcut: null));
  }
}
