part of project_boards;

class _ProjectBoardsController {
  _ProjectBoardsController._(this.api, this.projectName);

  final AzureApiService api;
  final String projectName;

  final projectBoards = ValueNotifier<ApiResponse<Map<Team, _BoardsAndSprints>?>?>(null);

  Future<void> init() async {
    await api.getWorkItemTypes();
    final boardsRes = await _getBoards();
    final sprintsRes = await _getSprints();

    if (boardsRes.isError) {
      projectBoards.value = ApiResponse.error(boardsRes.errorResponse);
      return;
    }

    if (sprintsRes.isError) {
      OverlayService.snackbar('Error getting sprints', isError: true);
    }

    final teamBoards = boardsRes.data!;
    final teamSprints = sprintsRes.data;

    final res = <Team, _BoardsAndSprints>{};

    for (final entry in teamBoards.entries) {
      final team = entry.key;
      final boards = entry.value;
      final sprints = teamSprints?[team] ?? [];

      res[team] = _BoardsAndSprints(boards: boards, sprints: sprints);
    }

    projectBoards.value = ApiResponse.ok(res);
  }

  Future<ApiResponse<Map<Team, List<Board>>>> _getBoards() async {
    final boardsRes = await api.getProjectBoards(projectName: projectName);
    return boardsRes;
  }

  Future<ApiResponse<Map<Team, List<Sprint>>>> _getSprints() async {
    final sprintsRes = await api.getProjectSprints(projectName: projectName);
    return sprintsRes;
  }

  void goToBoardDetail(Team team, Board board) {
    AppRouter.goToBoardDetail(
      args: (project: projectName, teamId: team.id, boardName: board.name, backlogId: board.backlogId!),
    );
  }

  void goToSprintDetail(Team team, Sprint sprint) {
    AppRouter.goToSprintDetail(
      args: (project: projectName, teamId: team.id, sprintId: sprint.id, sprintName: sprint.name),
    );
  }
}

class _BoardsAndSprints {
  _BoardsAndSprints({required this.boards, required this.sprints});

  final List<Board> boards;
  final List<Sprint> sprints;
}
