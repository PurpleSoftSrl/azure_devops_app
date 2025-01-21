part of commits;

class _CommitsController with FilterMixin, ApiErrorHelper {
  _CommitsController._(this.apiService, this.storageService, this.args, this.adsService) {
    if (args?.project != null) projectsFilter = {args!.project!};
    if (args?.author != null) usersFilter = {args!.author!};
  }

  final AzureApiService apiService;
  final StorageService storageService;
  final AdsService adsService;
  final CommitsArgs? args;

  final recentCommits = ValueNotifier<ApiResponse<List<Commit>?>?>(null);

  late final filtersService = FiltersService(
    storageService: storageService,
    organization: apiService.organization,
  );

  /// Read/write filters from local storage only if user is not coming from project page or from shortcut
  bool get shouldPersistFilters => args?.project == null && !hasShortcut;

  bool get hasShortcut => args?.shortcut != null;

  List<AdWithKey> ads = [];

  Future<void> init() async {
    if (shouldPersistFilters) {
      _fillSavedFilters();
    } else if (hasShortcut) {
      _fillShortcutFilters();
    }

    await _getNativeAds();

    await _getData();
  }

  void _fillSavedFilters() {
    final savedFilters = filtersService.getCommitsSavedFilters();
    _fillFilters(savedFilters);
  }

  void _fillShortcutFilters() {
    final savedFilters = filtersService.getCommitsShortcut(args!.shortcut!.label);
    _fillFilters(savedFilters);
  }

  void _fillFilters(CommitsFilters savedFilters) {
    if (savedFilters.projects.isNotEmpty) {
      projectsFilter = getProjects(storageService).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.authors.isNotEmpty) {
      usersFilter = getSortedUsers(apiService).where((p) => savedFilters.authors.contains(p.mailAddress)).toSet();
    }
  }

  Future<void> _getData() async {
    final res = await apiService.getRecentCommits(
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      authors: isDefaultUsersFilter ? null : usersFilter.map((u) => u.mailAddress ?? '').toSet(),
    );

    if (res.isError) {
      recentCommits.value = res;
      if (res.errorResponse?.statusCode == 404) {
        // ignore: unawaited_futures, to refresh the page immediately
        _handleBadRequest(res.errorResponse!);
      }
      return;
    }

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

    if (shouldPersistFilters) {
      filtersService.saveCommitsProjectsFilter(projects.map((p) => p.name!).toSet());
    }
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    recentCommits.value = null;
    usersFilter = users;
    _getData();

    if (shouldPersistFilters) {
      filtersService.saveCommitsAuthorsFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void resetFilters() {
    recentCommits.value = null;
    projectsFilter.clear();
    usersFilter.clear();

    if (shouldPersistFilters) {
      filtersService.resetCommitsFilters();
    }

    init();
  }

  Future<void> saveFilters() async {
    final shortcutLabel = await OverlayService.formBottomsheet(title: 'Choose a name', label: 'Name');
    if (shortcutLabel == null) return;

    final res = filtersService.saveCommitsShortcut(
      shortcutLabel,
      filters: CommitsFilters(
        projects: projectsFilter.map((p) => p.name!).toSet(),
        authors: usersFilter.map((u) => u.mailAddress!).toSet(),
      ),
    );

    OverlayService.snackbar(res.message, isError: !res.result);
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

        apiService.removeChosenProject(deletedProject);

        final updatedProjectFilter = {...projectsFilter}..removeWhere((p) => p.name == deletedProject);
        filterByProjects(updatedProjectFilter);
      }
    }
  }

  Future<void> _getNativeAds() async {
    final ads2 = await adsService.getNewNativeAds();
    ads = ads2.map((ad) => (ad: ad, key: GlobalKey())).toList();
  }
}
