part of board_detail;

class _BoardDetailController {
  _BoardDetailController._(this.api, this.args);

  final AzureApiService api;
  final BoardDetailArgs args;

  final boardWithItems = ValueNotifier<ApiResponse<BoardDetailWithItems>?>(null);

  final pageController = PageController(viewportFraction: .9);

  Future<void> init() async {
    final res = await api.getProjectBoard(projectName: args.project, teamId: args.teamId, backlogId: args.backlogId);
    boardWithItems.value = res;
  }

  Future<void> goToDetail(WorkItem item) async {
    await AppRouter.goToCreateOrEditWorkItem(args: (area: null, iteration: null, project: args.project, id: item.id));
    await init();
  }
}
