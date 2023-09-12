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
    projectFilter = project ?? projectAll;
  }

  static _WorkItemsController? instance;
  static final Map<int, _WorkItemsController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final workItems = ValueNotifier<ApiResponse<List<WorkItem>?>?>(null);

  late WorkItemState statusFilter = WorkItemState.all;
  WorkItemType typeFilter = WorkItemType.all;
  AreaOrIteration? areaFilter;
  AreaOrIteration? iterationFilter;

  late List<WorkItemType> allWorkItemTypes = [typeFilter];
  late List<WorkItemState> allWorkItemStates = [statusFilter];

  void dispose() {
    instance = null;
    _instances.remove(project.hashCode);
  }

  Future<void> init() async {
    allWorkItemTypes = [typeFilter];
    allWorkItemStates = [statusFilter];

    final types = await apiService.getWorkItemTypes();
    if (!types.isError) {
      allWorkItemTypes.addAll(types.data!.values.expand((ts) => ts).toSet());

      final allStatesToAdd = <WorkItemState>{};

      for (final entry in apiService.workItemStates.values) {
        final states = entry.values.expand((v) => v);
        allStatesToAdd.addAll(states);
      }

      final sortedStates = allStatesToAdd.sorted((a, b) => a.name.compareTo(b.name));

      allWorkItemStates.addAll(sortedStates);
    }

    await _getData();
  }

  Future<void> goToWorkItemDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(project: item.fields.systemTeamProject, id: item.id);
    await _getData();
  }

  void filterByProject(Project proj) {
    if (proj.id == projectFilter.id) return;

    workItems.value = null;
    projectFilter = proj.name == projectAll.name ? projectAll : proj;

    final projectAreas = apiService.workItemAreas[projectFilter.name!];

    if (projectAreas != null && projectAreas.isNotEmpty) {
      _resetAreaFilterIfNecessary(projectAreas);
    }

    _getData();
  }

  /// Resets [areaFilter] if selected [projectFilter] doesn't contain this area
  void _resetAreaFilterIfNecessary(List<AreaOrIteration> projectAreas) {
    var area = projectAreas.first;
    final flattenedAreas = <AreaOrIteration>[];

    while (area.hasChildren) {
      flattenedAreas.addAll([area, ...area.children!]);
      area = area.children!.first;
    }

    if (areaFilter != null && !flattenedAreas.contains(areaFilter)) {
      areaFilter = null;
    }
  }

  void filterByStatus(WorkItemState state) {
    if (state == statusFilter) return;

    workItems.value = null;
    statusFilter = state;
    _getData();
  }

  void filterByType(WorkItemType type) {
    if (type.name == typeFilter.name) return;

    workItems.value = null;
    typeFilter = type;
    _getData();
  }

  void filterByUser(GraphUser user) {
    if (user == userFilter) return;

    workItems.value = null;
    userFilter = user;
    _getData();
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
    var assignedTo = userFilter == userAll ? null : userFilter;
    if (userFilter.displayName == 'Unassigned') {
      assignedTo = GraphUser(mailAddress: '');
    }

    final res = await apiService.getWorkItems(
      project: projectFilter == projectAll ? null : projectFilter,
      type: typeFilter == WorkItemType.all ? null : typeFilter,
      status: statusFilter == WorkItemState.all ? null : statusFilter,
      assignedTo: assignedTo,
      area: areaFilter,
      iteration: iterationFilter,
    );
    workItems.value = res;
  }

  void resetFilters() {
    workItems.value = null;
    statusFilter = WorkItemState.all;
    typeFilter = WorkItemType.all;
    projectFilter = projectAll;
    userFilter = userAll;
    areaFilter = null;
    iterationFilter = null;

    init();
  }

  Future<void> createWorkItem() async {
    await AppRouter.goToCreateOrEditWorkItem();
    await init();
  }

  List<GraphUser> getAssignees() {
    final users = getSortedUsers(apiService);
    final unassigned = GraphUser(displayName: 'Unassigned');
    return users..insert(1, unassigned);
  }
}
