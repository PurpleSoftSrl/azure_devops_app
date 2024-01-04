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
          FilterMenu<PullRequestStatus>(
            title: 'Status',
            values: PullRequestStatus.values.where((s) => s != PullRequestStatus.notSet).toList(),
            currentFilter: ctrl.statusFilter,
            onSelected: ctrl.filterByStatus,
            isDefaultFilter: ctrl.statusFilter == PullRequestStatus.all,
            widgetBuilder: (s) => Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(backgroundColor: s.color),
            ),
          ),
          FilterMenu<GraphUser>.multiple(
            title: 'Opened by',
            values: ctrl.getSortedUsers(ctrl.apiService, withUserAll: false),
            currentFilters: ctrl.usersFilter,
            onSelectedMultiple: ctrl.filterByUsers,
            formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
            isDefaultFilter: ctrl.isDefaultUsersFilter,
            widgetBuilder: (u) => UserFilterWidget(user: u),
            onSearchChanged: ctrl.hasManyUsers(ctrl.apiService) ? (s) => ctrl.searchUser(s, ctrl.apiService) : null,
          ),
          FilterMenu<GraphUser>.multiple(
            title: 'Assigned to',
            values: ctrl.getSortedUsers(ctrl.apiService, withUserAll: false),
            currentFilters: ctrl.reviewersFilter,
            onSelectedMultiple: ctrl.filterByReviewers,
            formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
            isDefaultFilter: ctrl.reviewersFilter.isEmpty,
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
