part of board_detail;

class _BoardDetailController {
  _BoardDetailController._(this.api, this.args);

  final AzureApiService api;
  final BoardDetailArgs args;

  final boardWithItems = ValueNotifier<ApiResponse<BoardDetailWithItems>?>(null);

  final pageController = PageController(viewportFraction: .9);

  final columnItems = <BoardColumn, List<WorkItem>>{};

  Future<void> init() async {
    final res = await api.getProjectBoard(projectName: args.project, teamId: args.teamId, backlogId: args.backlogId);
    boardWithItems.value = res;

    final data = boardWithItems.value?.data;
    if (data == null) return;

    for (final column in data.board.columns) {
      columnItems[column] = [];

      final columnName = column.name;
      final itemsToAdd = data.items.where((item) => item.fields.boardColumn == columnName);

      columnItems[column]!.addAll(itemsToAdd);
    }
  }

  Future<void> goToDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(project: args.project, id: item.id);
    await init();
  }

  Future<void> addNewItem() async {}

  Future<void> editItem(WorkItem item) async {
    await AppRouter.goToCreateOrEditWorkItem(args: (area: null, iteration: null, project: args.project, id: item.id));
    await init();
  }

  void moveToColumn(WorkItem item) {}
}
