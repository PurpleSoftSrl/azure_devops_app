part of project_detail;

class _ProjectDetailController with ApiErrorHelper {
  _ProjectDetailController._(this.api, this.projectName);

  final AzureApiService api;

  final String projectName;

  final project = ValueNotifier<ApiResponse<ProjectDetail?>?>(null);

  List<TeamWithMembers> teamsWithMembers = <TeamWithMembers>[];
  List<GitRepository> repos = <GitRepository>[];
  List<LanguageBreakdown> languages = <LanguageBreakdown>[];
  List<SavedQuery> savedQueries = <SavedQuery>[];

  Iterable<LanguageBreakdown> get meaningfulLanguages => languages
      .where((l) => l.languagePercentage != null && l.languagePercentage! > 1)
      .sortedBy<num>((l) => l.languagePercentage!)
      .reversed;

  Future<void> init() async {
    final allRes = await Future.wait<ApiResponse>([_getLangs(), _getTeams(), _getRepos(), _getQueries()]);

    final projectRes = await api.getProject(projectName: projectName);

    if (projectRes.isError) {
      if (projectRes.errorResponse?.statusCode == 404) {
        // ignore: unawaited_futures, to refresh the page immediately
        _handleBadRequest(projectRes.errorResponse!);
      }
    }

    final isAllErrors = allRes.every((r) => r.isError);
    project.value = projectRes.copyWith(isError: isAllErrors, errorResponse: allRes.first.errorResponse);
  }

  void goToRepoDetail(GitRepository repo) {
    if (repo.defaultBranch == null) {
      OverlayService.error('Error', description: 'This repo seems empty.');
      return;
    }

    AppRouter.goToRepositoryDetail(RepoDetailArgs(projectName: projectName, repositoryName: repo.name!));
  }

  void goToSavedQueryDetail(SavedQuery query) {
    AppRouter.goToSavedQueries(args: (project: projectName, path: query.path, queryId: query.id));
  }

  void goToBoards() {
    AppRouter.goToProjectBoards(projectId: projectName);
  }

  void goToMemberDetail(TeamMember member) {
    AppRouter.goToMemberDetail(member.identity!.descriptor!);
  }

  Future<ApiResponse<List<LanguageBreakdown>>> _getLangs() async {
    final langs = await api.getProjectLanguages(projectName: projectName);
    languages = langs.data ?? [];
    return langs;
  }

  Future<ApiResponse<List<TeamWithMembers>>> _getTeams() async {
    final membersRes = await api.getProjectTeams(projectId: projectName);
    teamsWithMembers = membersRes.data ?? [];
    return membersRes;
  }

  Future<ApiResponse<List<GitRepository>>> _getRepos() async {
    final reposRes = await api.getProjectRepositories(projectName: projectName);
    repos = reposRes.data ?? [];
    return reposRes;
  }

  Future<ApiResponse<List<SavedQuery>>> _getQueries() async {
    final queriesRes = await api.getProjectSavedQueries(projectName: projectName);
    savedQueries = queriesRes.data ?? [];
    return queriesRes;
  }

  void goToCommits() {
    AppRouter.goToCommits(
      args: (project: project.value?.data?.project, author: null, repository: null, shortcut: null),
    );
  }

  void goToPipelines() {
    AppRouter.goToPipelines(args: (project: project.value?.data?.project, definition: null, shortcut: null));
  }

  void goToWorkItems() {
    AppRouter.goToWorkItems(args: (project: project.value?.data?.project, shortcut: null, savedQuery: null));
  }

  void goToPullRequests() {
    AppRouter.goToPullRequests(args: (project: project.value?.data?.project, shortcut: null));
  }

  Future<void> _handleBadRequest(Response response) async {
    final error = getErrorMessageAndType(response);
    if (error.type == projectNotFoundException) {
      final deletedProject = parseProjectNotFoundName(error.msg);
      if (deletedProject != null) {
        final conf = await OverlayService.confirm(
          'Project not found',
          description:
              'It looks like the project "$deletedProject" does not exist anymore. Do you want to remove it from your selected projects?',
        );
        if (!conf) return;

        api.removeChosenProject(deletedProject);

        AppRouter.pop();
      }
    }
  }
}
