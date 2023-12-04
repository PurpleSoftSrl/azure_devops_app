part of pull_requests;

class _PullRequestsScreen extends StatelessWidget {
  const _PullRequestsScreen(this.ctrl, this.parameters);

  final _PullRequestsController ctrl;
  final _PullRequestsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<PullRequest>?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Pull requests',
      notifier: ctrl.pullRequests,
      showScrollbar: true,
      onResetFilters: ctrl.resetFilters,
      onEmpty: 'No pull requests found',
      actions: [
        Flexible(
          child: DevOpsAnimatedSearchField(
            isSearching: ctrl.isSearching,
            onChanged: ctrl.searchPullRequests,
            onResetSearch: ctrl.resetSearch,
            hint: 'Search by id or title',
            margin: const EdgeInsets.only(left: 56, right: 16),
            child: SearchButton(isSearching: ctrl.isSearching),
          ),
        ),
      ],
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
          FilterMenu<PullRequestState>(
            title: 'Status',
            values: PullRequestState.values.where((s) => s != PullRequestState.notSet).toList(),
            currentFilter: ctrl.statusFilter,
            onSelected: ctrl.filterByStatus,
            isDefaultFilter: ctrl.statusFilter == PullRequestState.all,
            widgetBuilder: (s) => Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(backgroundColor: s.color),
            ),
          ),
          FilterMenu<GraphUser>(
            title: 'Opened by',
            values: ctrl.getSortedUsers(ctrl.apiService),
            currentFilter: ctrl.userFilter,
            onSelected: ctrl.filterByUser,
            formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
            isDefaultFilter: ctrl.userFilter == ctrl.userAll,
            widgetBuilder: (u) => UserFilterWidget(user: u),
            onSearchChanged: ctrl.hasManyUsers(ctrl.apiService) ? (s) => ctrl.searchUser(s, ctrl.apiService) : null,
          ),
          FilterMenu<GraphUser>(
            title: 'Assigned to',
            values: ctrl.getSortedUsers(ctrl.apiService),
            currentFilter: ctrl.reviewerFilter,
            onSelected: ctrl.filterByReviewer,
            formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
            isDefaultFilter: ctrl.reviewerFilter == ctrl.userAll,
            widgetBuilder: (u) => UserFilterWidget(user: u),
            onSearchChanged: ctrl.hasManyUsers(ctrl.apiService) ? (s) => ctrl.searchUser(s, ctrl.apiService) : null,
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
