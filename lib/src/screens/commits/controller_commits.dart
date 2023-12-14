part of commits;

class _CommitsController with FilterMixin {
  factory _CommitsController({
    required AzureApiService apiService,
    required StorageService storageService,
    CommitsArgs? args,
  }) {
    // handle page already in memory with a different project filter
    if (_instances[args] != null) {
      return _instances[args]!;
    }

    if (instance != null && args != instance!.args) {
      instance = _CommitsController._(apiService, storageService, args);
    }

    instance ??= _CommitsController._(apiService, storageService, args);
    return _instances.putIfAbsent(args, () => instance!);
  }

  _CommitsController._(this.apiService, this.storageService, this.args) {
    if (args?.project != null) projectsFilter = {args!.project!};
    if (args?.author != null) usersFilter = {args!.author!};
  }

  static _CommitsController? instance;
  static final Map<CommitsArgs?, _CommitsController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final CommitsArgs? args;

  final recentCommits = ValueNotifier<ApiResponse<List<Commit>?>?>(null);

  void dispose() {
    instance = null;
    _instances.remove(args);
  }

  Future<void> init() async {
    await _getData();
  }

  Future<void> _getData() async {
    final res = await apiService.getRecentCommits(
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      authors: isDefaultUsersFilter ? null : usersFilter.map((u) => u.mailAddress ?? '').toSet(),
    );
    var commits = (res.data ?? [])..sort((a, b) => b.author!.date!.compareTo(a.author!.date!));

    commits = commits.take(100).toList();

    final projectRepos = groupBy(commits, (c) => '${c.projectId}_${c.repositoryId}');
    final allTags = <TagsData?>[
      ...await Future.wait([
        for (final repoEntry in projectRepos.entries) apiService.getTags(repoEntry.value),
      ]),
    ]..removeWhere((data) => data == null || data.tags.isEmpty);

    if (allTags.isNotEmpty) {
      for (final commit in commits) {
        final repoTags =
            allTags.firstWhereOrNull((t) => t!.projectId == commit.projectId && t.repositoryId == commit.repositoryId);
        commit.tags = repoTags?.tags[commit.commitId];
      }
    }

    recentCommits.value = res.copyWith(data: commits);
  }

  Future<void> goToCommitDetail(Commit commit) async {
    await AppRouter.goToCommitDetail(
      project: commit.projectName,
      repository: commit.repositoryName,
      commitId: commit.commitId!,
    );
  }

  void filterByProjects(Set<Project> projects) {
    if (projects == projectsFilter) return;

    recentCommits.value = null;
    projectsFilter = projects;
    _getData();
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    recentCommits.value = null;
    usersFilter = users;
    _getData();
  }

  void resetFilters() {
    recentCommits.value = null;
    projectsFilter.clear();
    usersFilter.clear();
    init();
  }
}
