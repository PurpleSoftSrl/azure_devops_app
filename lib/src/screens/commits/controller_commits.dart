part of commits;

class _CommitsController with FilterMixin, ApiErrorHelper, AdsMixin {
  _CommitsController._(this.api, this.storage, this.args, this.ads) {
    if (args?.project != null) projectsFilter = {args!.project!};
    if (args?.author != null) usersFilter = {args!.author!};
  }

  final AzureApiService api;
  final StorageService storage;
  final AdsService ads;
  final CommitsArgs? args;

  final recentCommits = ValueNotifier<ApiResponse<List<Commit>?>?>(null);

  late final filtersService = FiltersService(
    storage: storage,
    organization: api.organization,
  );

  /// Read/write filters from local storage only if user is not coming from project page or from shortcut
  bool get shouldPersistFilters => args?.project == null && !hasShortcut;

  bool get hasShortcut => args?.shortcut != null;

  GitRepository? repositoryFilter;
  bool get isDefaultRepositoryFilter => repositoryFilter == null;

  String get _repositoryFilterKey => '${repositoryFilter!.project!.name}/${repositoryFilter!.name}';

  Future<void> init() async {
    if (shouldPersistFilters) {
      _fillSavedFilters();
    } else if (hasShortcut) {
      _fillShortcutFilters();
    }

    await _getDataAndAds();
  }

  Future<void> _getDataAndAds() async {
    await getNewNativeAds(ads);
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
      projectsFilter = getProjects(storage).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.authors.isNotEmpty) {
      usersFilter = getSortedUsers(api).where((p) => savedFilters.authors.contains(p.mailAddress)).toSet();
    }

    if (savedFilters.repository.isNotEmpty) {
      final repositoryName = savedFilters.repository.first.split('/').last;
      repositoryFilter = api.allRepositories.firstWhereOrNull((r) => r.name == repositoryName);
    }
  }

  Future<void> _getData() async {
    final res = await api.getRecentCommits(
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      authors: isDefaultUsersFilter ? null : usersFilter.map((u) => u.mailAddress ?? '').toSet(),
      repository: isDefaultRepositoryFilter ? null : repositoryFilter,
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
        for (final repoEntry in projectRepos.entries) api.getTags(repoEntry.value),
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
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveCommitsProjectsFilter(projects.map((p) => p.name!).toSet());
    }
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    recentCommits.value = null;
    usersFilter = users;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveCommitsAuthorsFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void filterByRepository(GitRepository? repository) {
    if (repository == repositoryFilter) return;

    recentCommits.value = null;
    repositoryFilter = repository;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveCommitsRepositoryFilter({if (repositoryFilter != null) _repositoryFilterKey});
    }
  }

  void resetFilters() {
    recentCommits.value = null;
    projectsFilter.clear();
    usersFilter.clear();
    repositoryFilter = null;

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
        repository: repositoryFilter == null ? {} : {_repositoryFilterKey},
      ),
    );

    OverlayService.snackbar(res.message, isError: !res.result);
  }

  List<GitRepository> getRepositoriesToShow() {
    return api.allRepositories
        .where(
          (r) => isDefaultProjectsFilter || (projectsFilter.map((p) => p.id).contains(r.project!.id)),
        )
        .toList();
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

        final updatedProjectFilter = {...projectsFilter}..removeWhere((p) => p.name == deletedProject);
        filterByProjects(updatedProjectFilter);
      }
    }
  }
}
