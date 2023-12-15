part of work_items;

class _WorkItemsController with FilterMixin {
  factory _WorkItemsController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    // handle page already in memory with a different project filter
    if (_instances[project.hashCode] != null) {
      return _instances[project.hashCode]!;
    }

    if (instance != null && project?.id != instance!.project?.id) {
      instance = _WorkItemsController._(apiService, storageService, project);
    }

    instance ??= _WorkItemsController._(apiService, storageService, project);
    return _instances.putIfAbsent(project.hashCode, () => instance!);
  }

  _WorkItemsController._(this.apiService, this.storageService, this.project) {
    if (project != null) projectsFilter = {project!};
  }

  static _WorkItemsController? instance;
  static final Map<int, _WorkItemsController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final workItems = ValueNotifier<ApiResponse<List<WorkItem>?>?>(null);
  List<WorkItem> allWorkItems = [];

  Set<WorkItemState> statesFilter = {};
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

  late final filtersService = FiltersService(storageService: storageService, apiService: apiService);

  void dispose() {
    instance = null;
    _instances.remove(project.hashCode);
  }

  Future<void> init() async {
    final savedFilters = filtersService.getWorkItemsSavedFilters();

    if (savedFilters.projects.isNotEmpty) {
      projectsFilter =
          getProjects(storageService).where((p) => savedFilters.projects.contains(p.name)).toSet();
    }

    if (savedFilters.assignees.isNotEmpty) {
      usersFilter = getAssignees().where((p) => savedFilters.assignees.contains(p.mailAddress)).toSet();
    }

    allWorkItemTypes = [];
    allWorkItemStates = statesFilter.toList();

    final types = await apiService.getWorkItemTypes();
    if (!types.isError) {
      _fillTypesAndStates(types.data!.values);

      if (savedFilters.types.isNotEmpty) {
        typesFilter = allWorkItemTypes.where((s) => savedFilters.types.contains(s.name)).toSet();
      }

      if (savedFilters.states.isNotEmpty) {
        statesFilter = allWorkItemStates.where((s) => savedFilters.states.contains(s.name)).toSet();
      }
    }

    await _getData();
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

    allWorkItemStates.addAll(sortedStates);
  }

  Future<void> goToWorkItemDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(project: item.fields.systemTeamProject, id: item.id);
    await _getData();
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

    _getData();

    filtersService.saveWorkItemsProjectsFilter(projects.map((p) => p.name!).toSet());
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
    _getData();

    filtersService.saveWorkItemsStatesFilter(states.map((p) => p.name).toSet());
  }

  void filterByTypes(Set<WorkItemType> types) {
    if (types == typesFilter) return;

    workItems.value = null;
    typesFilter = types;
    _getData();

    filtersService.saveWorkItemsTypesFilter(types.map((p) => p.name).toSet());
  }

  void filterByUsers(Set<GraphUser> users) {
    if (users == usersFilter) return;

    workItems.value = null;
    usersFilter = users;
    _getData();

    filtersService.saveWorkItemsAssigneesFilter(users.map((p) => p.mailAddress!).toSet());
  }

  void filterByArea(AreaOrIteration? area) {
    if (areaFilter != null && area?.id == areaFilter!.id) return;

    workItems.value = null;
    areaFilter = area;
    _getData();
  }

  void filterByIteration(AreaOrIteration? iteration) {
    if (iterationFilter != null && iteration?.id == iterationFilter!.id) return;

    workItems.value = null;
    iterationFilter = iteration;
    _getData();
  }

  Future<void> _getData() async {
    final assignedTo = isDefaultUsersFilter ? null : usersFilter;

    final res = await apiService.getWorkItems(
      projects: isDefaultProjectsFilter ? null : projectsFilter,
      types: typesFilter.isEmpty ? null : typesFilter,
      states: isDefaultStateFilter ? null : statesFilter,
      assignedTo: assignedTo?.map((u) => u.displayName == 'Unassigned' ? u.copyWith(mailAddress: '') : u).toSet(),
      area: areaFilter,
      iteration: iterationFilter,
    );

    allWorkItems = res.data ?? [];
    workItems.value = res;

    if (_currentSearchQuery != null) {
      _searchWorkItem(_currentSearchQuery!);
    }
  }

  void resetFilters() {
    workItems.value = null;
    statesFilter.clear();
    typesFilter.clear();
    projectsFilter.clear();
    usersFilter.clear();
    areaFilter = null;
    iterationFilter = null;
    _currentSearchQuery = null;

    filtersService.resetWorkItemsFilters();

    resetSearch();

    init();
  }

  Future<void> createWorkItem() async {
    await AppRouter.goToCreateOrEditWorkItem(
      args: (
        project: projectFilter != projectAll ? projectFilter.name : null,
        id: null,
        area: areaFilter?.path,
        iteration: iterationFilter?.path,
      ),
    );
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

  void showSearchField() {
    isSearching.value = true;
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
}
