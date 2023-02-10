part of home;

class _HomeScreen extends StatelessWidget {
  const _HomeScreen(this.ctrl, this.parameters);

  final _HomeController ctrl;
  final _HomeParameters parameters;

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return AppPageListenable<List<Project>>(
      notifier: ctrl.projects,
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: ctrl.apiService.organization,
      onEmpty: (onRetry) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No chosen projects'),
          const SizedBox(
            height: 48,
          ),
          LoadingButton(
            onPressed: onRetry,
            text: 'Choose some projects',
          ),
        ],
      ),
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
              _HomeItem(
                title: 'Commits',
                icon: DevOpsIcons.commit,
                onTap: ctrl.goToCommits,
                index: i++,
              ),
              _HomeItem(
                title: 'Pipelines',
                icon: DevOpsIcons.pipeline,
                onTap: ctrl.goToPipelines,
                index: i++,
              ),
              _HomeItem(
                title: 'Work items',
                icon: DevOpsIcons.task,
                onTap: ctrl.goToWorkItems,
                index: i++,
              ),
              _HomeItem(
                title: 'Pull requests',
                icon: DevOpsIcons.pullrequest,
                onTap: ctrl.goToPullRequests,
                index: i++,
              ),
            ],
          ),
          SectionHeader.withIcon(
            text: 'Projects',
            icon: DevOpsIcons.list,
          ),
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
