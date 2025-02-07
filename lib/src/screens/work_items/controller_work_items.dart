part of work_items;

class _WorkItemsController with FilterMixin, ApiErrorHelper, AdsMixin {
  _WorkItemsController._(this.apiService, this.storageService, this.args, this.adsService) {
    if (args?.project != null) projectsFilter = {args!.project!};
  }

  final AzureApiService apiService;
  final StorageService storageService;
  final AdsService adsService;
  final WorkItemsArgs? args;

  final workItems = ValueNotifier<ApiResponse<List<WorkItem>?>?>(null);
  List<WorkItem> allWorkItems = [];

  Set<WorkItemState> statesFilter = {};
  Set<WorkItemStateCategory> stateCategoriesFilter = {};
  Set<WorkItemType> typesFilter = {};
  AreaOrIteration? areaFilter;
  AreaOrIteration? iterationFilter;

  /// Used to show only active iterations in iteration filter
  final showActiveIterations = ValueNotifier<bool>(false);

  late List<WorkItemType> allWorkItemTypes = [];
  late List<WorkItemState> allWorkItemStates = statesFilter.toList();

  final isSearching = ValueNotifier<bool>(false);
  String? _currentSearchQuery;

  bool get isDefaultStateFilter => statesFilter.isEmpty;
  bool get isDefaultStateCategoryFilter => stateCategoriesFilter.isEmpty;

  late final filtersService = FiltersService(
    storageService: storageService,
    organization: apiService.organization,
  );

  /// Read/write filters from local storage only if user is not coming from project page or from shortcut
  bool get shouldPersistFilters => args == null && !hasShortcut;

  bool get hasShortcut => args?.shortcut != null;

  bool get hasSavedQuery => args?.savedQuery != null;

  final savedQuery = ValueNotifier<SavedQuery?>(null);

  Future<void> init() async {
    WorkItemsFilters? savedFilters;
    if (shouldPersistFilters) {
      savedFilters = _fillSavedFilters();
    } else if (hasShortcut) {
      _fillShortcutFilters();
    }

    allWorkItemTypes = [];
    allWorkItemStates = statesFilter.toList();

    final types = await apiService.getWorkItemTypes();
    if (!types.isError) {
      _fillTypesAndStates(types.data!.values);

      if (shouldPersistFilters) {
        if (savedFilters?.types.isNotEmpty ?? false) {
          typesFilter = allWorkItemTypes.where((s) => savedFilters!.types.contains(s.name)).toSet();
        }

        if (savedFilters?.states.isNotEmpty ?? false) {
          statesFilter = allWorkItemStates.where((s) => savedFilters!.states.contains(s.name)).toSet();
        }
      }
    }

    await _getDataAndAds();

    if (shouldPersistFilters) {
      if (savedFilters?.area.isNotEmpty ?? false) {
        areaFilter = apiService.workItemAreas.values
            .expand((a) => a)
            .expand((a) => [a, if (a.children != null) ...a.children!])
            .firstWhereOrNull((a) => a.path == savedFilters!.area.first);
      }

      if (savedFilters?.iteration.isNotEmpty ?? false) {
        apiService.workItemIterations.values
            .expand((a) => a)
            .expand((a) => [a, if (a.children != null) ...a.children!])
            .firstWhereOrNull((a) => a.path == savedFilters!.iteration.first);
      }
    }
  }

  Future<void> _getDataAndAds() async {
    await getNewNativeAds(adsService);
    await _getData();
  }

  /// Here we fill some filters with fake objects just to show them immediately,
  /// because we may not have the real object yet (areas, iterations, types and states
  /// need to get downloaded).
  WorkItemsFilters _fillSavedFilters() {
    final savedFilters = filtersService.getWorkItemsSavedFilters();
    return _fillFilters(savedFilters);
  }

  WorkItemsFilters _fillShortcutFilters() {
    final savedFilters = filtersService.getWorkItemsShortcut(args!.shortcut!.label);
    return _fillFilters(savedFilters);
  }

  WorkItemsFilters _fillFilters(WorkItemsFilters savedFilters) {
    if (savedFilters.projects.isNotEmpty) {
      projectsFilter = getProjects(storageService).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.assignees.isNotEmpty) {
      usersFilter = getAssignees().where((p) => savedFilters.assignees.contains(p.mailAddress)).toSet();
    }

    if (savedFilters.area.isNotEmpty) {
      areaFilter = AreaOrIteration.onlyPath(path: savedFilters.area.first);
    }

    if (savedFilters.iteration.isNotEmpty) {
      iterationFilter = AreaOrIteration.onlyPath(path: savedFilters.iteration.first);
    }

    if (savedFilters.types.isNotEmpty) {
      typesFilter = savedFilters.types.map((t) => WorkItemType.onlyName(name: t)).toSet();
    }

    if (savedFilters.states.isNotEmpty) {
      statesFilter = savedFilters.states.map((s) => WorkItemState.onlyName(name: s)).toSet();
    }

    if (savedFilters.categories.isNotEmpty) {
      stateCategoriesFilter = savedFilters.categories.map(WorkItemStateCategory.fromString).toSet();
    }

    return savedFilters;
  }

  void _fillTypesAndStates(Iterable<List<WorkItemType>> values) {
    final typeList = values.expand((ts) => ts).toSet();

    final distinctTypeIds = <String>{};

    // get distinct types by name
    for (final type in typeList) {
      if (distinctTypeIds.add(type.name)) {
        allWorkItemTypes.add(type);
      }
    }

    final allStatesToAdd = <WorkItemState>{};

    for (final entry in apiService.workItemStates.values) {
      final states = entry.values.expand((v) => v);
      allStatesToAdd.addAll(states);
    }

    final sortedStates = allStatesToAdd.sorted((a, b) => a.name.compareTo(b.name));

    allWorkItemStates = sortedStates;
  }

  Future<void> goToWorkItemDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(project: item.fields.systemTeamProject, id: item.id);
    await _getDataAndAds();
  }

  void filterByProjects(Set<Project> projects) {
    if (projects == projectsFilter) return;

    workItems.value = null;
    projectsFilter = projects;

    for (final project in projectsFilter) {
      final projectAreas = apiService.workItemAreas[project.name!];
      if (projectAreas != null && projectAreas.isNotEmpty) {
        _resetAreaFilterIfNecessary(projectAreas);
      }

      final projectIterations = apiService.workItemIterations[project.name!];
      if (projectIterations != null && projectIterations.isNotEmpty) {
        _resetIterationFilterIfNecessary(projectIterations);
      }
    }

    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveWorkItemsProjectsFilter(projects.map((p) => p.name!).toSet());
    }
  }

  /// Resets [areaFilter] if selected [projectFilter] doesn't contain this area
  void _resetAreaFilterIfNecessary(List<AreaOrIteration> projectAreas) {
    final flattenedAreas = _flattenList(projectAreas);

    if (areaFilter != null && !flattenedAreas.contains(areaFilter)) {
      areaFilter = null;
    }
  }

  /// Resets [iterationFilter] if selected [projectFilter] doesn't contain this iteration
  void _resetIterationFilterIfNecessary(List<AreaOrIteration> projectIterations) {
    final flattenedIterations = _flattenList(projectIterations);

    if (iterationFilter != null && !flattenedIterations.contains(iterationFilter)) {
      iterationFilter = null;
    }
  }

  List<AreaOrIteration> _flattenList(List<AreaOrIteration> areasOrIterations) {
    var area = areasOrIterations.first;
    final flattened = <AreaOrIteration>[];

    while (area.hasChildren) {
      flattened.addAll([area, ...area.children!]);
      area = area.children!.first;
    }

    return flattened;
  }

  void filterByStates(Set<WorkItemState> states) {
    if (states == statesFilter) return;

    workItems.value = null;
    statesFilter = states;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveWorkItemsStatesFilter(states.map((p) => p.name).toSet());
    }
  }

  void filterByStateCategory(Set<WorkItemStateCategory> categories) {
    if (categories == stateCategoriesFilter) return;

    workItems.value = null;
    stateCategoriesFilter = categories;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveWorkItemsCategoriesFilter(stateCategoriesFilter.map((p) => p.name).toSet());
    }
  }

  void filterByTypes(Set<WorkItemType> types) {
    if (types == typesFilter) return;

    workItems.value = null;
    typesFilter = types;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveWorkItemsTypesFilter(types.map((p) => p.name).toSet());
    }
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    workItems.value = null;
    usersFilter = users;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveWorkItemsAssigneesFilter(users.map((p) => p.mailAddress!).toSet());
    }
  }

  void filterByArea(AreaOrIteration? area) {
    if (areaFilter != null && area?.id == areaFilter!.id) return;

    workItems.value = null;
    areaFilter = area;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveWorkItemsAreaFilter(area?.path ?? '');
    }
  }

  void filterByIteration(AreaOrIteration? iteration) {
    if (iterationFilter != null && iteration?.id == iterationFilter!.id) return;

    workItems.value = null;
    iterationFilter = iteration;
    _getDataAndAds();

    if (shouldPersistFilters) {
      filtersService.saveWorkItemsIterationFilter(iteration?.path ?? '');
    }
  }

  Future<void> _getData() async {
    final assignedTo = isDefaultUsersFilter ? null : usersFilter;

    var states = isDefaultStateFilter ? null : statesFilter;

    if (!isDefaultStateCategoryFilter) {
      states = allWorkItemStates
          .where((s) => stateCategoriesFilter.map((s) => s.stringValue.replaceAll(' ', '')).contains(s.stateCategory))
          .toSet();
    }

    if (hasSavedQuery) {
      final savedQueryRes = await apiService.getProjectSavedQuery(
        projectName: args!.savedQuery!.projectId,
        queryId: args!.savedQuery!.id,
      );
      savedQuery.value = savedQueryRes.data;
    }

    final res = await apiService.getWorkItems(
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      types: typesFilter.isEmpty ? null : typesFilter,
      states: states,
      assignedTo: assignedTo?.map((u) => u.displayName == 'Unassigned' ? u.copyWith(mailAddress: '') : u).toSet(),
      area: areaFilter,
      iteration: iterationFilter,
      savedQuery: savedQuery.value?.wiql,
    );

    allWorkItems = res.data ?? [];
    workItems.value = res;

    if (_currentSearchQuery != null) {
      _searchWorkItem(_currentSearchQuery!);
    }

    if (res.isError && res.errorResponse?.statusCode == 400) {
      // ignore: unawaited_futures, to refresh the page immediately
      _handleBadRequest(res.errorResponse!);
    }
  }

  void resetFilters() {
    workItems.value = null;
    statesFilter.clear();
    stateCategoriesFilter.clear();
    typesFilter.clear();
    projectsFilter.clear();
    usersFilter.clear();
    areaFilter = null;
    iterationFilter = null;
    _currentSearchQuery = null;

    if (shouldPersistFilters) {
      filtersService.resetWorkItemsFilters();
    }

    resetSearch();

    init();
  }

  Future<void> createWorkItem() async {
    final createItemArgs = CreateOrEditWorkItemArgs(
      project: projectsFilter.length != 1 ? null : projectsFilter.first.name,
      area: areaFilter?.path,
      iteration: iterationFilter?.path,
    );
    await AppRouter.goToCreateOrEditWorkItem(args: createItemArgs);

    await init();
  }

  List<GraphUser> getAssignees() {
    final users = getSortedUsers(apiService, withUserAll: false);
    final unassigned = GraphUser(displayName: 'Unassigned', mailAddress: 'unassigned');
    return users..insert(0, unassigned);
  }

  /// If user has selected a project show only areas of the selected project,
  /// and don't show areas that are identical to the project (projects with default area only).
  Iterable<AreaOrIteration> getAreasToShow() {
    final hasProjectFilter = projectsFilter.isNotEmpty;

    bool hasRealChildren(List<AreaOrIteration>? as) =>
        as != null && (as.length > 1 || (as.first.children?.isNotEmpty ?? false));

    final areas = apiService.workItemAreas;

    if (areas.isEmpty) return [];

    if (hasProjectFilter) {
      return projectsFilter.map((p) => areas[p.name!]).where(hasRealChildren).expand((a) => a ?? <AreaOrIteration>[]);
    }

    return areas.values.where(hasRealChildren).expand((a) => a);
  }

  // If user has selected an area show only iterations of the project which the area belongs to,
  // otherwise if user has selected a project show only iterations of the selected project,
  // otherwise show all iterations.
  Iterable<AreaOrIteration> getIterationsToShow() {
    final iterations = apiService.workItemIterations;
    if (iterations.isEmpty) return [];

    final hasProjectFilter = projectsFilter.isNotEmpty;
    final projectIterations = hasProjectFilter
        ? projectsFilter.map((p) => iterations[p.name!]).expand((i) => i ?? <AreaOrIteration>[])
        : null;

    final hasAreaFilter = areaFilter != null;
    final areaProjectIterations = hasAreaFilter ? iterations[areaFilter?.projectName] : null;

    return areaProjectIterations ?? projectIterations ?? iterations.values.expand((a) => a);
  }

  void toggleShowActiveIterations() {
    showActiveIterations.value = !showActiveIterations.value;
  }

  /// Search currently filtered work items by id or title.
  void _searchWorkItem(String query) {
    _currentSearchQuery = query.trim().toLowerCase();

    final matchedItems = allWorkItems
        .where(
          (i) =>
              i.id.toString().contains(_currentSearchQuery!) ||
              i.fields.systemTitle.toLowerCase().contains(_currentSearchQuery!),
        )
        .toList();

    workItems.value = workItems.value?.copyWith(data: matchedItems);
  }

  void resetSearch() {
    _searchWorkItem('');
    _hideSearchField();
  }

  void _hideSearchField() {
    isSearching.value = false;
  }

  List<GraphUser> searchAssignee(String query) {
    final loweredQuery = query.toLowerCase().trim();
    final users = getAssignees();
    return users.where((u) => u.displayName != null && u.displayName!.toLowerCase().contains(loweredQuery)).toList();
  }

  Future<void> saveFilters() async {
    final shortcutLabel = await OverlayService.formBottomsheet(title: 'Choose a name', label: 'Name');
    if (shortcutLabel == null) return;

    final res = filtersService.saveWorkItemsShortcut(
      shortcutLabel,
      filters: WorkItemsFilters(
        projects: projectsFilter.map((p) => p.name!).toSet(),
        states: statesFilter.map((s) => s.name).toSet(),
        categories: stateCategoriesFilter.map((c) => c.name).toSet(),
        types: typesFilter.map((t) => t.name).toSet(),
        assignees: usersFilter.map((u) => u.mailAddress!).toSet(),
        area: {if (areaFilter?.path != null) areaFilter!.path},
        iteration: {if (iterationFilter?.path != null) iterationFilter!.path},
      ),
    );

    OverlayService.snackbar(res.message, isError: !res.result);
  }

  Future<void> _handleBadRequest(Response response) async {
    final objectName = getWorkItemErrorObjectName(response);

    if (isWorkItemProjectNotFoundError(response.body)) {
      final deletedProject = objectName;
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

      return;
    }

    if (isWorkItemIterationNotFoundError(response.body)) {
      final deletedIteration = objectName;
      if (deletedIteration != null) {
        final conf = await OverlayService.confirm(
          'Iteration not found',
          description:
              'It looks like the iteration "$deletedIteration" does not exist anymore. Do you want to remove it from the filters?',
        );
        if (!conf) return;

        await apiService.getWorkItemTypes(force: true);
        filterByIteration(null);
      }

      return;
    }

    if (isWorkItemAreaNotFoundError(response.body)) {
      final deletedArea = objectName;
      if (deletedArea != null) {
        final conf = await OverlayService.confirm(
          'Area not found',
          description:
              'It looks like the area "$deletedArea" does not exist anymore. Do you want to remove it from the filters?',
        );
        if (!conf) return;

        await apiService.getWorkItemTypes(force: true);
        filterByArea(null);
      }

      return;
    }
  }
}
