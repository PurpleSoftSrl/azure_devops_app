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
      onEmpty: (onRetry) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No commits found'),
          const SizedBox(
            height: 50,
          ),
          LoadingButton(
            onPressed: onRetry,
            text: 'Reset filters',
          ),
        ],
      ),
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
          ),
          if (ctrl.getSortedUsers(ctrl.apiService).length > 1)
            FilterMenu<GraphUser>.user(
              title: 'Author',
              values: ctrl.getSortedUsers(ctrl.apiService),
              currentFilter: ctrl.userFilter,
              onSelected: ctrl.filterByUser,
              formatLabel: (u) => u.displayName!,
              isDefaultFilter: ctrl.userFilter == ctrl.userAll,
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
