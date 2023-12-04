part of commits;

class _CommitsScreen extends StatelessWidget {
  const _CommitsScreen(this.ctrl, this.parameters);

  final _CommitsController ctrl;
  final _CommitsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<Commit>?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Commits',
      notifier: ctrl.recentCommits,
      showScrollbar: true,
      onResetFilters: ctrl.resetFilters,
      onEmpty: 'No commits found',
      header: () => FiltersRow(
        resetFilters: ctrl.resetFilters,
        filters: [
          FilterMenu<Project>(
            title: 'Project',
            values: ctrl.getProjects(ctrl.storageService),
            currentFilter: ctrl.projectFilter,
            onSelected: ctrl.filterByProject,
            formatLabel: (p) => p.name!,
            isDefaultFilter: ctrl.projectFilter == ctrl.projectAll,
            widgetBuilder: (p) => ProjectFilterWidget(project: p),
            onSearchChanged:
                ctrl.hasManyProjects(ctrl.storageService) ? (s) => ctrl.searchProject(s, ctrl.storageService) : null,
          ),
          FilterMenu<GraphUser>(
            title: 'Author',
            values: ctrl.getSortedUsers(ctrl.apiService),
            currentFilter: ctrl.userFilter,
            onSelected: ctrl.filterByUser,
            formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
            isDefaultFilter: ctrl.userFilter == ctrl.userAll,
            widgetBuilder: (u) => UserFilterWidget(user: u),
            onSearchChanged: ctrl.hasManyUsers(ctrl.apiService) ? (s) => ctrl.searchUser(s, ctrl.apiService) : null,
          ),
        ],
      ),
      builder: (commits) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: commits!
            .map(
              (c) => CommitListTile(
                commit: c,
                onTap: () => ctrl.goToCommitDetail(c),
                isLast: c == commits.last,
              ),
            )
            .toList(),
      ),
    );
  }
}
