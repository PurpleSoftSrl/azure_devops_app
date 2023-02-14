part of work_items;

class _WorkItemsScreen extends StatelessWidget {
  const _WorkItemsScreen(this.ctrl, this.parameters);

  final _WorkItemsController ctrl;
  final _WorkItemsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<List<WorkItem>?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Work items',
      notifier: ctrl.workItems,
      actions: [
        IconButton(
          onPressed: ctrl.createWorkItem,
          icon: Icon(
            DevOpsIcons.plus,
            size: 24,
          ),
        ),
      ],
      onEmpty: (onRetry) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No work items found'),
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
          FilterMenu<String>(
            title: 'Status',
            values: WorkItemExt.allStates,
            currentFilter: ctrl.statusFilter,
            onSelected: ctrl.filterByStatus,
            isDefaultFilter: ctrl.statusFilter == ctrl._workItemStateAll,
          ),
          FilterMenu<WorkItemType>(
            title: 'Type',
            values: WorkItemType.values,
            currentFilter: ctrl.typeFilter,
            onSelected: ctrl.filterByType,
            isDefaultFilter: ctrl.typeFilter == WorkItemType.all,
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
      builder: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items!
            .map(
              (i) => _WorkItemListTile(
                item: i,
                onTap: () => ctrl.goToWorkItemDetail(i),
                isLast: i == items.last,
              ),
            )
            .toList(),
      ),
    );
  }
}
