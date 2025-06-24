part of pipelines;

class _PipelinesScreen extends StatelessWidget {
  const _PipelinesScreen(this.ctrl, this.parameters);

  final _PipelinesController ctrl;
  final _PipelinesParameters parameters;

  @override
  Widget build(BuildContext context) {
    final definition = ctrl.args?.definition;
    return VisibilityDetector(
      key: ctrl.visibilityKey,
      onVisibilityChanged: ctrl.visibilityChanged,
      child: AppPage<List<Pipeline>?>(
        init: ctrl.init,
        dispose: ctrl.dispose,
        title: 'Pipelines ${definition != null ? '(#$definition)' : ''}',
        notifier: ctrl.pipelines,
        showScrollbar: true,
        onResetFilters: ctrl.resetFilters,
        onEmpty: 'No pipelines found',
        header: () => ctrl.hasShortcut
            ? ShortcutLabel(
                label: ctrl.args!.shortcut!.label,
              )
            : FiltersRow(
                resetFilters: ctrl.resetFilters,
                saveFilters: ctrl.saveFilters,
                filters: [
                  if (ctrl.args?.definition == null)
                    FilterMenu<Project>.multiple(
                      title: 'Projects',
                      values: ctrl.getProjects(ctrl.storage, withProjectAll: false),
                      currentFilters: ctrl.projectsFilter,
                      onSelectedMultiple: ctrl.filterByProjects,
                      formatLabel: (p) => p.name!,
                      isDefaultFilter: ctrl.isDefaultProjectsFilter,
                      widgetBuilder: (p) => ProjectFilterWidget(project: p),
                      onSearchChanged:
                          ctrl.hasManyProjects(ctrl.storage) ? (s) => ctrl.searchProject(s, ctrl.storage) : null,
                    ),
                  if (ctrl.showPipelineNamesFilter)
                    FilterMenu<String>.multiple(
                      title: 'Pipelines',
                      values: ctrl.getPipelineNames(),
                      currentFilters: ctrl.pipelineNamesFilter,
                      onSelectedMultiple: ctrl.filterByPipelines,
                      formatLabel: (p) => p,
                      isDefaultFilter: ctrl.isDefaultPipelineNamesFilter,
                      showLeading: false,
                      widgetBuilder: (p) => const SizedBox(),
                    ),
                  FilterMenu<PipelineResult>(
                    title: 'Result',
                    values: PipelineResult.values.where((v) => v != PipelineResult.none).toList(),
                    currentFilter: ctrl.resultFilter,
                    onSelected: ctrl.filterByResult,
                    isDefaultFilter: ctrl.resultFilter == PipelineResult.all,
                    widgetBuilder: (r) => r.icon,
                  ),
                  if (ctrl.resultFilter == PipelineResult.all)
                    FilterMenu<PipelineStatus>(
                      title: 'Status',
                      values: PipelineStatus.values.where((v) => v != PipelineStatus.none).toList(),
                      currentFilter: ctrl.statusFilter,
                      onSelected: ctrl.filterByStatus,
                      isDefaultFilter: ctrl.statusFilter == PipelineStatus.all,
                      widgetBuilder: (s) => s.icon,
                    ),
                  FilterMenu<GraphUser>.multiple(
                    title: 'Triggered by',
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
        sliverBuilder: (pipelines) {
          var adsIndex = 0;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: pipelines?.length ?? 0,
              (_, index) {
                final p = pipelines![index];

                if (index == 0) {
                  return Column(
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      if (ctrl.inProgressPipelines > 0) Text('Running pipelines: ${ctrl.inProgressPipelines}'),
                      if (ctrl.queuedPipelines > 0) Text('Queued pipelines: ${ctrl.queuedPipelines}'),
                      if (ctrl.inProgressPipelines > 0 || ctrl.queuedPipelines > 0)
                        const SizedBox(
                          height: 24,
                        ),
                      PipelineListTile(
                        pipe: p,
                        onTap: () => ctrl.goToPipelineDetail(p),
                        isLast: p == pipelines.last,
                      ),
                    ],
                  );
                }

                if (ctrl.shouldShowNativeAd(pipelines, p, adsIndex)) {
                  return Column(
                    children: [
                      PipelineListTile(
                        pipe: p,
                        onTap: () => ctrl.goToPipelineDetail(p),
                        isLast: p == pipelines.last,
                      ),
                      CustomAdWidget(
                        item: ctrl.ads.hasAmazonAds ? ctrl.amazonAds[adsIndex++] : ctrl.nativeAds[adsIndex++],
                      ),
                    ],
                  );
                }

                return PipelineListTile(
                  pipe: p,
                  onTap: () => ctrl.goToPipelineDetail(p),
                  isLast: p == pipelines.last,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
