part of pipelines;

class _PipelinesScreen extends StatelessWidget {
  const _PipelinesScreen(this.ctrl, this.parameters);

  final _PipelinesController ctrl;
  final _PipelinesParameters parameters;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ctrl.visibilityKey,
      onVisibilityChanged: ctrl.visibilityChanged,
      child: AppPage<List<Pipeline>?>(
        init: ctrl.init,
        dispose: ctrl.dispose,
        title: 'Pipelines',
        notifier: ctrl.pipelines,
        showScrollbar: true,
        onResetFilters: ctrl.resetFilters,
        onEmpty: 'No pipelines found',
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
            FilterMenu<GraphUser>(
              title: 'Triggered by',
              values: ctrl.getSortedUsers(ctrl.apiService),
              currentFilter: ctrl.userFilter,
              onSelected: ctrl.filterByUser,
              formatLabel: (u) => u.displayName!,
              isDefaultFilter: ctrl.userFilter == ctrl.userAll,
              widgetBuilder: (u) => UserFilterWidget(user: u),
            ),
          ],
        ),
        builder: (pipelines) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            ...pipelines!.map(
              (p) => PipelineListTile(
                pipe: p,
                onTap: () => ctrl.goToPipelineDetail(p),
                isLast: p == pipelines.last,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
