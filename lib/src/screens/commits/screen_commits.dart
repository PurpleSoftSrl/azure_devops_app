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
        saveFilters: ctrl.saveFilters,
        filters: [
          FilterMenu<Project>.multiple(
            title: 'Projects',
            values: ctrl.getProjects(ctrl.storageService, withProjectAll: false),
            currentFilters: ctrl.projectsFilter,
            onSelectedMultiple: ctrl.filterByProjects,
            formatLabel: (p) => p.name!,
            isDefaultFilter: ctrl.isDefaultProjectsFilter,
            widgetBuilder: (p) => ProjectFilterWidget(project: p),
            onSearchChanged:
                ctrl.hasManyProjects(ctrl.storageService) ? (s) => ctrl.searchProject(s, ctrl.storageService) : null,
          ),
          FilterMenu<GraphUser>.multiple(
            title: 'Authors',
            values: ctrl.getSortedUsers(ctrl.apiService, withUserAll: false),
            currentFilters: ctrl.usersFilter,
            onSelectedMultiple: ctrl.filterByUsers,
            formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
            isDefaultFilter: ctrl.isDefaultUsersFilter,
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
