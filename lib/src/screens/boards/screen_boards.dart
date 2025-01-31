part of boards;

class _BoardsScreen extends StatelessWidget {
  const _BoardsScreen(this.ctrl, this.parameters);

  final _BoardsController ctrl;
  final _BoardsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<Project>?>(
      init: ctrl.init,
      title: 'Boards',
      notifier: ctrl.allProjects,
      showScrollbar: true,
      builder: (projects) => Column(
        children: projects!
            .map(
              (p) => ProjectCard(
                height: parameters.projectCardHeight,
                project: p,
                onTap: ctrl.goToProjectBoards,
              ),
            )
            .toList(),
      ),
    );
  }
}
