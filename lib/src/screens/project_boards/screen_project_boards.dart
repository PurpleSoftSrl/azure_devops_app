part of project_boards;

class _ProjectBoardsScreen extends StatelessWidget {
  const _ProjectBoardsScreen(this.ctrl, this.parameters);

  final _ProjectBoardsController ctrl;
  final _ProjectBoardsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<Map<Team, List<Board>>?>(
      init: ctrl.init,
      title: ctrl.projectName,
      notifier: ctrl.projectBoards,
      builder: (boards) => Column(
        children: boards!.entries
            .map(
              (teamBoards) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamBoards.key.name,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ...teamBoards.value.map(
                    (board) => NavigationButton(
                      onTap: () => ctrl.goToBoardDetail(teamBoards.key, board),
                      margin: board == teamBoards.value.first ? EdgeInsets.zero : const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(board.name)),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
