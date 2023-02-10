part of pull_requests;

class _PullRequestsScreen extends StatelessWidget {
  const _PullRequestsScreen(this.ctrl, this.parameters);

  final _PullRequestsController ctrl;
  final _PullRequestsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<List<PullRequest>?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Pull requests',
      notifier: ctrl.pullRequests,
      onEmpty: (onRetry) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No pull requests found'),
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
          FilterMenu<PullRequestState>(
            title: 'Status',
            values: PullRequestState.values,
            currentFilter: ctrl.statusFilter,
            onSelected: ctrl.filterByStatus,
            isDefaultFilter: ctrl.statusFilter == PullRequestState.all,
          ),
          FilterMenu<GraphUser>.user(
            title: 'Opened by',
            values: ctrl.users,
            currentFilter: ctrl.userFilter,
            onSelected: ctrl.filterByUser,
            formatLabel: (u) => u.displayName!,
            isDefaultFilter: ctrl.userFilter == ctrl._userAll,
          ),
          FilterMenu<Project>(
            title: 'Project',
            values: ctrl.projects,
            currentFilter: ctrl.projectFilter,
            onSelected: ctrl.filterByProject,
            formatLabel: (p) => p.name!,
            isDefaultFilter: ctrl.projectFilter == ctrl.allProject,
          ),
        ],
      ),
      builder: (prs) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: prs!
            .map(
              (pr) => PullRequestListTile(
                pr: pr,
                onTap: () => ctrl.goToPullRequestDetail(pr),
                isLast: pr == prs.last,
              ),
            )
            .toList(),
      ),
    );
  }
}
