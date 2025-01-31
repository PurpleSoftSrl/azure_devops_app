part of board_detail;

class _BoardDetailController {
  _BoardDetailController._(this.api, this.args);

  final AzureApiService api;
  final BoardDetailArgs args;

  final boardWithItems = ValueNotifier<ApiResponse<BoardDetailWithItems>?>(null);

  final pageController = PageController(viewportFraction: .9);

  final columnItems = <BoardColumn, List<WorkItem>>{};

  Set<String> get _allowedTypes =>
      boardWithItems.value?.data?.board.columns.firstOrNull?.stateMappings.keys.toSet() ?? {};

  Future<void> init() async {
    final res = await api.getProjectBoard(projectName: args.project, teamId: args.teamId, backlogId: args.backlogId);
    boardWithItems.value = res;

    final data = boardWithItems.value?.data;
    if (data == null) return;

    for (final column in data.board.columns) {
      columnItems[column] = [];

      final columnName = column.name;
      final itemsToAdd = data.items
          .where((item) => item.fields.boardColumn == columnName)
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
    final areaPath = boardWithItems.value?.data?.items.firstOrNull?.fields.systemAreaPath;
    if (areaPath == null) return;

    final addItemArgs = CreateOrEditWorkItemArgs(
      area: areaPath,
      project: args.project,
      isAreaVisible: false,
      allowedTypes: _allowedTypes,
    );
    await AppRouter.goToCreateOrEditWorkItem(args: addItemArgs);
    await init();
  }

  Future<void> editItem(WorkItem item) async {
    final editItemArgs = CreateOrEditWorkItemArgs(
      project: args.project,
      id: item.id,
      isAreaVisible: false,
      allowedTypes: _allowedTypes,
    );
    await AppRouter.goToCreateOrEditWorkItem(args: editItemArgs);
    await init();
  }

  void moveToColumn(WorkItem item) {}
}
