part of pull_requests;

class _PullRequestsController with FilterMixin, ApiErrorHelper, AdsMixin {
  _PullRequestsController._(this.api, this.storage, this.args, this.ads) {
    if (args?.project != null) projectsFilter = {args!.project!};
  }

  final AzureApiService api;
  final StorageService storage;
  final AdsService ads;
  final PullRequestArgs? args;

  final pullRequests = ValueNotifier<ApiResponse<List<PullRequest>?>?>(null);
  List<PullRequest> allPullRequests = [];

  PullRequestStatus statusFilter = PullRequestStatus.all;

  Set<GraphUser> reviewersFilter = {};

  final isSearching = ValueNotifier<bool>(false);
  String? _currentSearchQuery;

  late final filtersService = FiltersService(storage: storage, organization: api.organization);

  /// Read/write filters from local storage only if user is not coming from project page or from shortcut
  bool get shouldPersistFilters => args?.project == null && !hasShortcut;

  bool get hasShortcut => args?.shortcut != null;

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
    final savedFilters = filtersService.getPullRequestsSavedFilters();
    _fillFilters(savedFilters);
  }

  void _fillShortcutFilters() {
    final savedFilters = filtersService.getPullRequestsShortcut(args!.shortcut!.label);
    _fillFilters(savedFilters);
  }

  void _fillFilters(PullRequestsFilters savedFilters) {
    if (savedFilters.projects.isNotEmpty) {
      projectsFilter = getProjects(storage).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.status.isNotEmpty) {
      statusFilter = PullRequestStatus.fromString(savedFilters.status.first);
    }

    if (savedFilters.openedBy.isNotEmpty) {
      usersFilter = getSortedUsers(api).where((p) => savedFilters.openedBy.contains(p.mailAddress)).toSet();
    }

    if (savedFilters.assignedTo.isNotEmpty) {
      reviewersFilter = getSortedUsers(api).where((p) => savedFilters.assignedTo.contains(p.mailAddress)).toSet();
    }
  }

  Future<void> goToPullRequestDetail(PullRequest pr) async {
    await AppRouter.goToPullRequestDetail(
      project: pr.repository.project.name,
      repository: pr.repository.id,
      id: pr.pullRequestId,
    );
    await init();
  }

  void filterByStatus(PullRequestStatus status) {
    if (status == statusFilter) return;

    pullRequests.value = null;
    statusFilter = status;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsStatusFilter(status.name);
    }
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    pullRequests.value = null;
    usersFilter = users;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsOpenedByFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void filterByReviewers(Set<GraphUser> users) {
    if (users == reviewersFilter) return;

    pullRequests.value = null;
    reviewersFilter = users;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsAssignedToFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void filterByProjects(Set<Project> projects) {
    if (projects == projectsFilter) return;

    pullRequests.value = null;
    projectsFilter = projects;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.savePullRequestsProjectsFilter(projects.map((p) => p.name!).toSet());
    }
  }

  Future<void> _getData() async {
    final res = await api.getPullRequests(
      status: statusFilter,
      creators: isDefaultUsersFilter ? null : usersFilter,
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      reviewers: reviewersFilter.isEmpty ? null : reviewersFilter,
    );

    if (res.isError) {
      pullRequests.value = res;
      if (res.errorResponse?.statusCode == 404) {
        // ignore: unawaited_futures, to refresh the page immediately
        _handleBadRequest(res.errorResponse!);
      }
      return;
    }

    pullRequests.value = res..data?.sort((a, b) => (b.creationDate).compareTo(a.creationDate));
    allPullRequests = pullRequests.value?.data ?? [];

    if (_currentSearchQuery != null) {
      searchPullRequests(_currentSearchQuery!);
    }
  }

  void resetFilters() {
    pullRequests.value = null;
    projectsFilter.clear();
    statusFilter = PullRequestStatus.all;
    usersFilter.clear();
    reviewersFilter.clear();

    if (shouldPersistFilters) {
      filtersService.resetPullRequestsFilters();
    }

    init();
  }

  void searchPullRequests(String query) {
    _currentSearchQuery = query.trim().toLowerCase();

    final matchedItems = allPullRequests
        .where(
          (i) =>
              i.pullRequestId.toString().contains(_currentSearchQuery!) ||
              i.title.toLowerCase().contains(_currentSearchQuery!),
        )
        .toList();

    pullRequests.value = pullRequests.value?.copyWith(data: matchedItems);
  }

  void resetSearch() {
    searchPullRequests('');
    isSearching.value = false;
  }

  Future<void> saveFilters() async {
    final shortcutLabel = await OverlayService.formBottomsheet(title: 'Choose a name', label: 'Name');
    if (shortcutLabel == null) return;

    final res = filtersService.savePullRequestsShortcut(
      shortcutLabel,
      filters: PullRequestsFilters(
        projects: projectsFilter.map((p) => p.name!).toSet(),
        status: {if (statusFilter != PullRequestStatus.all) statusFilter.name},
        openedBy: usersFilter.map((u) => u.mailAddress!).toSet(),
        assignedTo: reviewersFilter.map((u) => u.mailAddress!).toSet(),
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

        api.removeChosenProject(deletedProject);

        final updatedProjectFilter = {...projectsFilter}..removeWhere((p) => p.name == deletedProject);
        filterByProjects(updatedProjectFilter);
      }
    }
  }
}
