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
      instance = null;
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

  late final filtersService = FiltersService(
    storageService: storageService,
    organization: apiService.organization,
  );

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    _fillSavedFilters();

    await _getData();
  }

  void _fillSavedFilters() {
    final savedFilters = filtersService.getCommitsSavedFilters();
    final project = projectsFilter.firstOrNull;

    if (savedFilters.projects.isNotEmpty && project == null) {
      projectsFilter = getProjects(storageService).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.authors.isNotEmpty &&
        ((project != null && savedFilters.projects.contains(project.name)) || project == null)) {
      usersFilter = getSortedUsers(apiService).where((p) => savedFilters.authors.contains(p.mailAddress)).toSet();
    }
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

    filtersService.saveCommitsProjectsFilter(projects.map((p) => p.name!).toSet());
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    recentCommits.value = null;
    usersFilter = users;
    _getData();

    filtersService.saveCommitsAuthorsFilter(users.map((p) => p.mailAddress!).toSet());
  }

  void resetFilters() {
    recentCommits.value = null;
    projectsFilter.clear();
    usersFilter.clear();

    filtersService.resetCommitsFilters();

    init();
  }
}
