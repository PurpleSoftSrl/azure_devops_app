part of sprint_detail;

class _SprintDetailController with FilterMixin {
  _SprintDetailController._(this.api, this.args);

  final AzureApiService api;
  final SprintDetailArgs args;

  final sprintWithItems = ValueNotifier<ApiResponse<SprintDetailWithItems>?>(null);
  final columnItems = <BoardColumn, List<WorkItem>>{};

  Set<WorkItemType> typesFilter = {};
  List<WorkItemType> allWorkItemTypes = [];

  Set<String> get _allowedTypes => _data?.sprint.types?.toSet() ?? {'Task', 'Bug', 'User Story'};

  SprintDetailWithItems? _data;

  Future<void> init() async {
    final res = await api.getProjectSprint(projectName: args.project, teamId: args.teamId, sprintId: args.sprintId);

    _data = res.data;

    allWorkItemTypes = [];

    _fillColumns();
    await _fillTypesFilter();

    sprintWithItems.value = res;
  }

  void _fillColumns() {
    if (_data == null) return;

    for (final column in _data!.sprint.columns ?? <BoardColumn>[]) {
      columnItems[column] = [];

      final columnName = column.name;
      final itemsToAdd = _data!.items
          .where((item) => item.fields.systemState == columnName)
          .sortedBy((item) => item.fields.systemChangedDate)
          .reversed;

      final filteredByTypes = typesFilter.isEmpty
          ? itemsToAdd
          : itemsToAdd.where((i) => typesFilter.map((t) => t.name).contains(i.fields.systemWorkItemType)).toList();

      final filteredByUsers = usersFilter.isEmpty
          ? filteredByTypes
          : filteredByTypes
              .where(
                (i) => usersFilter
                    .map((u) => u.displayName == 'Unassigned' ? '' : u.mailAddress)
                    .contains(i.fields.systemAssignedTo?.uniqueName ?? ''),
              )
              .toList();

      columnItems[column]!.addAll(filteredByUsers);
    }
  }

  Future<void> addNewItem() async {
    final sprint = _data?.sprint;

    final areaPath = sprint?.teamDefaultArea;
    if (areaPath == null) return;

    final iterationPath = sprint?.path;
    if (iterationPath == null) return;

    final addItemArgs = CreateOrEditWorkItemArgs(
      area: areaPath,
      iteration: iterationPath,
      project: args.project,
      isAreaVisible: false,
      isIterationVisible: false,
      allowedTypes: _allowedTypes,
    );

    await AppRouter.goToCreateOrEditWorkItem(args: addItemArgs);
    await init();
  }

  Future<void> goToDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(project: args.project, id: item.id);
    await init();
  }

  Future<void> editItem(WorkItem item) async {
    final sprint = _data?.sprint;

    final areaPath = sprint?.teamDefaultArea;
    if (areaPath == null) return;

    final iterationPath = sprint?.path;
    if (iterationPath == null) return;

    final editItemArgs = CreateOrEditWorkItemArgs(
      project: args.project,
      area: areaPath,
      iteration: iterationPath,
      id: item.id,
      isAreaVisible: false,
      isIterationVisible: false,
      allowedTypes: _allowedTypes,
    );
    await AppRouter.goToCreateOrEditWorkItem(args: editItemArgs);
    await init();
  }

  Future<void> _fillTypesFilter() async {
    final types = await api.getWorkItemTypes();
    if (types.isError) return;

    final typeList = types.data!.values.expand((ts) => ts).where((t) => _allowedTypes.contains(t.name)).toSet();

    final distinctTypeIds = <String>{};

    // get distinct types by name
    for (final type in typeList) {
      if (distinctTypeIds.add(type.name)) {
        allWorkItemTypes.add(type);
      }
    }
  }

  List<GraphUser> getAssignees() {
    final users = getSortedUsers(api, withUserAll: false);
    final unassigned = GraphUser(displayName: 'Unassigned', mailAddress: 'unassigned');
    return users..insert(0, unassigned);
  }

  void filterByTypes(Set<WorkItemType> types) {
    typesFilter = types;

    _fillColumns();
    _refreshUI();
  }

  void filterByUsers(Set<GraphUser> users) {
    usersFilter = users;

    _fillColumns();
    _refreshUI();
  }

  List<GraphUser> searchAssignee(String query) {
    final loweredQuery = query.toLowerCase().trim();
    final users = getAssignees();
    return users.where((u) => u.displayName != null && u.displayName!.toLowerCase().contains(loweredQuery)).toList();
  }

  void _refreshUI() {
    sprintWithItems.value = sprintWithItems.value!.copyWith();
  }

  void resetFilters() {
    sprintWithItems.value = null;
    columnItems.clear();

    typesFilter.clear();
    usersFilter.clear();

    init();
  }
}
