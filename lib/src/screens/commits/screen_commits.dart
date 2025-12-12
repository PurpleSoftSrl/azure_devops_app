part of commits;

class _CommitsScreen extends StatelessWidget {
  const _CommitsScreen(this.ctrl, this.parameters);

  final _CommitsController ctrl;
  final _CommitsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<Commit>?>(
      init: ctrl.init,
      title: 'Commits',
      notifier: ctrl.recentCommits,
      showScrollbar: true,
      onResetFilters: ctrl.resetFilters,
      onEmpty: 'No commits found',
      header: () => ctrl.hasShortcut
          ? ShortcutLabel(label: ctrl.args!.shortcut!.label)
          : FiltersRow(
              resetFilters: ctrl.resetFilters,
              saveFilters: ctrl.saveFilters,
              filters: [
                if (ctrl.repositoryFilter == null)
                  FilterMenu<Project>.multiple(
                    title: 'Projects',
                    values: ctrl.getProjects(ctrl.storage, withProjectAll: false),
                    currentFilters: ctrl.projectsFilter,
                    onSelectedMultiple: ctrl.filterByProjects,
                    formatLabel: (p) => p.name!,
                    isDefaultFilter: ctrl.isDefaultProjectsFilter,
                    widgetBuilder: (p) => ProjectFilterWidget(project: p),
                    onSearchChanged: ctrl.hasManyProjects(ctrl.storage)
                        ? (s) => ctrl.searchProject(s, ctrl.storage)
                        : null,
                  ),
                if (ctrl.api.allRepositories.isNotEmpty)
                  FilterMenu<GitRepository>.custom(
                    title: 'Repository',
                    currentFilter: ctrl.repositoryFilter,
                    formatLabel: (r) => r.name!,
                    isDefaultFilter: ctrl.isDefaultRepositoryFilter,
                    body: _RepositoryFilterBody(
                      repositories: ctrl.getRepositoriesToShow(),
                      onTap: ctrl.filterByRepository,
                      selectedRepository: ctrl.repositoryFilter,
                    ),
                  ),
                FilterMenu<GraphUser>.multiple(
                  title: 'Authors',
                  values: ctrl.getSortedUsers(ctrl.api, withUserAll: false),
                  currentFilters: ctrl.usersFilter,
                  onSelectedMultiple: ctrl.filterByUsers,
                  formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.api),
                  isDefaultFilter: ctrl.isDefaultUsersFilter,
                  widgetBuilder: (u) => UserFilterWidget(user: u),
                  onSearchChanged: ctrl.hasManyUsers(ctrl.api) ? (s) => ctrl.searchUser(s, ctrl.api) : null,
                ),
              ],
            ),
      sliverBuilder: (commits) {
        var adsIndex = 0;

        return SliverList(
          delegate: SliverChildBuilderDelegate(childCount: commits?.length ?? 0, (_, index) {
            final c = commits![index];

            if (ctrl.shouldShowNativeAd(commits, c, adsIndex)) {
              return Column(
                children: [
                  CommitListTile(commit: c, onTap: () => ctrl.goToCommitDetail(c), isLast: c == commits.last),
                  CustomAdWidget(item: ctrl.ads.hasAmazonAds ? ctrl.amazonAds[adsIndex++] : ctrl.nativeAds[adsIndex++]),
                ],
              );
            }

            return CommitListTile(commit: c, onTap: () => ctrl.goToCommitDetail(c), isLast: c == commits.last);
          }),
        );
      },
    );
  }
}
