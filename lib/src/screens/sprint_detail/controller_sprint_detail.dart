part of sprint_detail;

class _SprintDetailController {
  _SprintDetailController._(this.api, this.args);

  final AzureApiService api;
  final SprintDetailArgs args;

  final sprintWithItems = ValueNotifier<ApiResponse<SprintDetailWithItems>?>(null);
  final columnItems = <BoardColumn, List<WorkItem>>{};

  Future<void> init() async {
    final res = await api.getProjectSprint(projectName: args.project, teamId: args.teamId, sprintId: args.sprintId);
    sprintWithItems.value = res;

    final data = sprintWithItems.value?.data;
    if (data == null) return;

    for (final column in data.sprint.columns ?? <BoardColumn>[]) {
      columnItems[column] = [];

      final columnName = column.name;
      final itemsToAdd = data.items
          .where((item) => item.fields.systemState == columnName)
          .sortedBy((item) => item.fields.systemChangedDate)
          .reversed;

      columnItems[column]!.addAll(itemsToAdd);
    }
  }

  Future<void> goToDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(project: args.project, id: item.id);
    await init();
  }

  Future<void> addNewItem() async {
    final sprint = sprintWithItems.value?.data?.sprint;

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
      allowedTypes: {'Task', 'Bug', 'User Story'},
    );

    await AppRouter.goToCreateOrEditWorkItem(args: addItemArgs);
    await init();
  }
}
