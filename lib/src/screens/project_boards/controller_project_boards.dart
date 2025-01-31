part of project_boards;

class _ProjectBoardsController {
  _ProjectBoardsController._(this.api, this.projectName);

  final AzureApiService api;
  final String projectName;

  final projectBoards = ValueNotifier<ApiResponse<Map<Team, List<Board>>?>?>(null);

  Future<void> init() async {
    await api.getWorkItemTypes();
    await _getBoards();
  }

  Future<void> _getBoards() async {
    final boardsRes = await api.getProjectBoards(projectName: projectName);
    projectBoards.value = boardsRes;
  }

  void goToBoardDetail(Team team, Board board) {
    AppRouter.goToBoardDetail(
      args: (project: projectName, teamId: team.id, boardId: board.name, backlogId: board.backlogId!),
    );
  }
}
