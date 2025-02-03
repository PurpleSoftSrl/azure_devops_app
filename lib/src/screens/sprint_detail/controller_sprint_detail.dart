part of sprint_detail;

class _SprintDetailController {
  _SprintDetailController._(this.api, this.args);

  final AzureApiService api;
  final SprintDetailArgs args;

  final sprintWithItems = ValueNotifier<ApiResponse<SprintDetailWithItems>?>(null);
  final pageController = PageController(viewportFraction: .9);
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
}
