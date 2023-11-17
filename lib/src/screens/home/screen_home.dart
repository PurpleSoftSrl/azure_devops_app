part of home;

class _HomeScreen extends StatelessWidget {
  const _HomeScreen(this.ctrl, this.parameters);

  final _HomeController ctrl;
  final _HomeParameters parameters;

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return AppPage<List<Project>>(
      notifier: ctrl.projects,
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: ctrl.apiService.organization,
      builder: (projects) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader.withIcon(
            text: 'Work',
            icon: DevOpsIcons.repository,
            marginTop: 0,
          ),
          GridView.count(
            crossAxisCount: 2,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: parameters.gridItemAspectRatio,
            crossAxisSpacing: 13,
            mainAxisSpacing: 18,
            children: [
              WorkCard(
                title: 'Commits',
                icon: DevOpsIcons.commit,
                onTap: ctrl.goToCommits,
                index: i++,
              ),
              WorkCard(
                title: 'Pipelines',
                icon: DevOpsIcons.pipeline,
                onTap: ctrl.goToPipelines,
                index: i++,
              ),
              WorkCard(
                title: 'Work items',
                icon: DevOpsIcons.task,
                onTap: ctrl.goToWorkItems,
                index: i++,
              ),
              WorkCard(
                title: 'Pull requests',
                icon: DevOpsIcons.pullrequest,
                onTap: ctrl.goToPullRequests,
                index: i++,
              ),
            ],
          ),
          if (ctrl.hasManyProjects)
            _ProjectsHeaderWithSearchField(ctrl: ctrl)
          else
            SectionHeader.withIcon(
              text: 'Projects',
              icon: DevOpsIcons.list,
            ),
          if (projects.isEmpty)
            Text(
              'No project found',
              style: context.textTheme.labelLarge,
            )
          else
            ...projects.map(
              (p) => _ProjectCard(
                parameters: parameters,
                project: p,
                onTap: ctrl.goToProjectDetail,
              ),
            ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
