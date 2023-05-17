part of pipelines;

class _PipelinesScreen extends StatelessWidget {
  const _PipelinesScreen(this.ctrl, this.parameters);

  final _PipelinesController ctrl;
  final _PipelinesParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<Pipeline>?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Pipelines',
      notifier: ctrl.pipelines,
      showScrollbar: true,
      onResetFilters: ctrl.resetFilters,
      onEmpty: (onRetry) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No pipelines found'),
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
          FilterMenu<Project>.bottomsheet(
            title: 'Project',
            values: ctrl.getProjects(ctrl.storageService),
            currentFilter: ctrl.projectFilter,
            onSelected: ctrl.filterByProject,
            formatLabel: (p) => p.name!,
            isDefaultFilter: ctrl.projectFilter == ctrl.projectAll,
          ),
          FilterMenu<PipelineResult>(
            title: 'Result',
            values: PipelineResult.values.where((v) => v != PipelineResult.none).toList(),
            currentFilter: ctrl.resultFilter,
            onSelected: ctrl.filterByResult,
            isDefaultFilter: ctrl.resultFilter == PipelineResult.all,
          ),
          FilterMenu<PipelineStatus>(
            title: 'Status',
            values: PipelineStatus.values.where((v) => v != PipelineStatus.none).toList(),
            currentFilter: ctrl.statusFilter,
            onSelected: ctrl.filterByStatus,
            isDefaultFilter: ctrl.statusFilter == PipelineStatus.all,
          ),
          FilterMenu<GraphUser>.bottomsheet(
            title: 'Triggered by',
            values: ctrl.getSortedUsers(ctrl.apiService),
            currentFilter: ctrl.userFilter,
            onSelected: ctrl.filterByUser,
            formatLabel: (u) => u.displayName!,
            isDefaultFilter: ctrl.userFilter == ctrl.userAll,
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
    );
  }
}
