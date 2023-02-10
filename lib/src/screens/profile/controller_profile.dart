part of profile;

class _ProfileController {
  factory _ProfileController({required AzureApiService apiService}) {
    return instance ??= _ProfileController._(apiService);
  }

  _ProfileController._(this.apiService);

  static _ProfileController? instance;

  final AzureApiService apiService;

  final recentCommits = ValueNotifier<ApiResponse<List<Commit>?>?>(null);

  String gitUsername = '';

  GraphUser? author;

  Iterable<Commit> get todaysCommits => recentCommits.value?.data?.where((c) => c.author!.date!.isToday()) ?? [];

  int get todaysCommitsCount => todaysCommits.length;

  Map<String, Map<String, List<Commit>>> get todaysCommitsPerRepo {
    final groupedByProject = groupBy(todaysCommits, (c) => c.projectName);

    return <String, Map<String, List<Commit>>>{
      for (final g in groupedByProject.entries) g.key: groupBy(g.value, (c) => c.repositoryName),
    };
  }

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    gitUsername = apiService.user?.emailAddress ?? '';

    final commits = await _getData();

    final authorRes = await apiService.getUserFromEmail(email: apiService.user!.emailAddress!);
    author = authorRes.data;

    commits.data?.sort((a, b) => b.author!.date!.compareTo(a.author!.date!));

    final res = commits.data?.take(100).toList();

    recentCommits.value = ApiResponse.ok(res);
  }

  Future<void> goToCommitDetail(Commit c) async {
    await AppRouter.goToCommitDetail(c);
  }

  Future<ApiResponse<List<Commit>>> _getData() async {
    return apiService.getRecentCommits(author: gitUsername);
  }

  String getSummary() {
    final projectsCount = todaysCommitsPerRepo.keys.length;
    final reposCount = todaysCommitsPerRepo.values.fold(0, (a, b) => a + b.keys.length);
    final commits = todaysCommitsCount == 1 ? 'commit' : 'commits';
    final repos = reposCount == 1 ? 'repo' : 'repos';
    final projects = projectsCount == 1 ? 'project' : 'projects';
    return '$todaysCommitsCount $commits in $reposCount $repos in $projectsCount $projects';
  }
}
