part of profile;

class _ProfileController with FilterMixin, AdsMixin {
  _ProfileController._(this.apiService, this.storageService, this.adsService);

  final AzureApiService apiService;
  final StorageService storageService;
  final AdsService adsService;

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

  final myWorkItems = <WorkItem>[];

  Future<void> init() async {
    gitUsername = apiService.user?.emailAddress ?? '';
    myWorkItems.clear();

    final commits = await _getData();

    final authorRes = await apiService.getUserFromEmail(email: apiService.user!.emailAddress!);
    author = authorRes.data;

    commits.data?.sort((a, b) => b.author!.date!.compareTo(a.author!.date!));

    final res = commits.data?.take(100).toList();

    final myWorkItemsRes = await apiService.getMyRecentWorkItems();
    myWorkItems.addAll(myWorkItemsRes.data ?? []);

    await getNewNativeAds(adsService);

    recentCommits.value = commits.copyWith(data: res);
  }

  Future<void> goToCommitDetail(Commit commit) async {
    await AppRouter.goToCommitDetail(
      project: commit.projectName,
      repository: commit.repositoryName,
      commitId: commit.commitId!,
    );
  }

  Future<ApiResponse<List<Commit>>> _getData() async {
    return apiService.getRecentCommits(authors: {gitUsername});
  }

  String getCommitsSummary() {
    final projectsCount = todaysCommitsPerRepo.keys.length;
    final reposCount = todaysCommitsPerRepo.values.fold(0, (a, b) => a + b.keys.length);
    final commits = todaysCommitsCount == 1 ? 'commit' : 'commits';
    final repos = reposCount == 1 ? 'repo' : 'repos';
    final projects = projectsCount == 1 ? 'project' : 'projects';
    return '$todaysCommitsCount $commits in $reposCount $repos in $projectsCount $projects';
  }

  String getWorkItemsSummary() {
    final workItemsCount = myWorkItems.length;
    final items = workItemsCount > 1 ? 'items' : 'item';
    return '$workItemsCount work $items updated';
  }

  void goToWorkItemDetail(WorkItem item) {
    AppRouter.goToWorkItemDetail(project: item.fields.systemTeamProject, id: item.id);
  }

  void goToCommits(Commit commit) {
    final project = getProjects(storageService).firstWhereOrNull((p) => p.id == commit.projectId);

    final me = apiService.allUsers.firstWhereOrNull((u) => u.mailAddress == apiService.user?.emailAddress);
    AppRouter.goToCommits(project: project, author: me);
  }
}
