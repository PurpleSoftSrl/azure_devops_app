part of project_boards;

class _ProjectBoardsScreen extends StatelessWidget {
  const _ProjectBoardsScreen(this.ctrl, this.parameters);

  final _ProjectBoardsController ctrl;
  final _ProjectBoardsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<Map<Team, _BoardsAndSprints>?>(
      init: ctrl.init,
      title: ctrl.projectName,
      notifier: ctrl.projectBoards,
      builder: (boards) {
        final teamBoards = {
          for (final teamBoard in boards!.entries) teamBoard.key: teamBoard.value.boards,
        };

        final teamSprints = {
          for (final teamSprint in boards.entries.where((e) => e.value.sprints.isNotEmpty))
            teamSprint.key: teamSprint.value.sprints,
        };

        return Column(
          children: [
            Text(
              'Boards',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(
              height: 8,
            ),
            ...teamBoards.entries.map(
              (tb) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tb.key.name,
                    style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ...tb.value.map(
                    (board) => NavigationButton(
                      onTap: () => ctrl.goToBoardDetail(tb.key, board),
                      margin: board == tb.value.first ? EdgeInsets.zero : const EdgeInsets.only(top: 8),
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
            ),
            const SizedBox(
              height: 32,
            ),
            if (teamSprints.isNotEmpty) ...[
              Text(
                'Sprints',
                style: context.textTheme.headlineSmall,
              ),
              ...teamSprints.entries.where((ts) => ts.value.isNotEmpty).map(
                    (ts) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ts.key.name,
                          style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        ...groupBy(ts.value, (ts) => ts.attributes.timeFrame)
                            .entries
                            .sortedBy((entry) => entry.key)
                            .map(
                              (entry) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    entry.key.titleCase,
                                    style: context.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  ...entry.value.map(
                                    (sprint) => NavigationButton(
                                      onTap: () => ctrl.goToSprintDetail(ts.key, sprint),
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(sprint.name)),
                                          Icon(Icons.arrow_forward_ios),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
            ],
          ],
        );
      },
    );
  }
}
