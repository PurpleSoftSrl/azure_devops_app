part of commits;

class _CommitsScreen extends StatelessWidget {
  const _CommitsScreen(this.ctrl, this.parameters);

  final _CommitsController ctrl;
  final _CommitsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<List<Commit>?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Commits',
      notifier: ctrl.recentCommits,
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
            values: ctrl.projects,
            currentFilter: ctrl.projectFilter,
            onSelected: ctrl.filterByProject,
            formatLabel: (p) => p.name!,
            isDefaultFilter: ctrl.projectFilter == ctrl.allProject,
          ),
          FilterMenu<GraphUser>.user(
            title: 'Author',
            values: ctrl.users,
            currentFilter: ctrl.userFilter,
            onSelected: ctrl.filterByUser,
            formatLabel: (u) => u.displayName!,
            isDefaultFilter: ctrl.userFilter == ctrl._userAll,
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
