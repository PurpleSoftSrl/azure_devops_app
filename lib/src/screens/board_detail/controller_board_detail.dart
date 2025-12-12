part of board_detail;

class _BoardDetailController with ApiErrorHelper, AdsMixin, FilterMixin {
  _BoardDetailController._(this.api, this.args, this.ads);

  final AzureApiService api;
  final AdsService ads;
  final BoardDetailArgs args;

  final boardWithItems = ValueNotifier<ApiResponse<BoardDetailWithItems>?>(null);
  final columnItems = <BoardColumn, List<WorkItem>>{};

  Set<WorkItemType> typesFilter = {};
  List<WorkItemType> allWorkItemTypes = [];

  BoardDetailWithItems? _data;

  Set<String> get _allowedTypes => _data?.board.columns.firstOrNull?.stateMappings.keys.toSet() ?? {};

  final isSearching = ValueNotifier<bool>(false);
  String? _currentSearchQuery;

  Future<void> init() async {
    final res = await api.getProjectBoard(projectName: args.project, teamId: args.teamId, backlogId: args.backlogId);
    _data = res.data;

    allWorkItemTypes = [];

    _fillColumns();
    await _fillTypesFilter();

    boardWithItems.value = res;
  }

  void _fillColumns() {
    if (_data == null) return;

    for (final column in _data!.board.columns) {
      columnItems[column] = [];

      final columnName = column.name;
      final itemsToAdd = _data!.items
          .where((i) => i.fields.boardColumn == columnName)
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

      final matchedItems = (_currentSearchQuery ?? '').isEmpty
          ? filteredByUsers
          : filteredByUsers
                .where(
                  (i) =>
                      i.id.toString().contains(_currentSearchQuery!) ||
                      i.fields.systemTitle.toLowerCase().contains(_currentSearchQuery!),
                )
                .toList();

      columnItems[column]!.addAll(matchedItems);
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
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c)]),
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
    boardWithItems.value = boardWithItems.value!.copyWith();
  }

  void resetFilters() {
    boardWithItems.value = null;
    columnItems.clear();

    typesFilter.clear();
    usersFilter.clear();

    _currentSearchQuery = null;
    _hideSearchField();

    init();
  }

  /// Search currently filtered work items by id or title.
  void _searchWorkItem(String query) {
    _currentSearchQuery = query.trim().toLowerCase();

    _fillColumns();
    _refreshUI();
  }

  void resetSearch() {
    _searchWorkItem('');
    _hideSearchField();
  }

  void _hideSearchField() {
    isSearching.value = false;
  }
}
