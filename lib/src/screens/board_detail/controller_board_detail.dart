part of board_detail;

class _BoardDetailController with ApiErrorHelper, AdsMixin {
  _BoardDetailController._(this.api, this.args, this.ads);

  final AzureApiService api;
  final AdsService ads;
  final BoardDetailArgs args;

  final boardWithItems = ValueNotifier<ApiResponse<BoardDetailWithItems>?>(null);
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

  Future<void> moveToColumn(WorkItem item) async {
    final columns = columnItems.keys.map((c) => c.name).where((c) => c != item.fields.boardColumn);

    String? column;

    await OverlayService.bottomsheet(
      title: 'Choose a column',
      builder: (context) => Column(
        children: columns
            .map(
              (c) => NavigationButton(
                margin: const EdgeInsets.all(8),
                onTap: () {
                  column = c;
                  AppRouter.popRoute();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(c)],
                ),
              ),
            )
            .toList(),
      ),
    );

    if (column == null) return;

    final res = await api.editWorkItem(
      projectName: args.project,
      id: item.id,
      formFields: {boardWithItems.value!.data!.board.fields.columnField.referenceName: column!},
    );

    if (res.isError) {
      final errorMessage = getErrorMessageAndType(res.errorResponse!);
      return OverlayService.error('Error', description: 'Item not updated.\n${errorMessage.msg}');
    }

    await showInterstitialAd(
      ads,
      onDismiss: () => OverlayService.snackbar('Item successfully moved to column $column'),
    );

    await init();
  }
}
