part of work_items;

class _WorkItemsScreen extends StatelessWidget {
  const _WorkItemsScreen(this.ctrl, this.parameters);

  final _WorkItemsController ctrl;
  final _WorkItemsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<WorkItem>?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'Work items',
      notifier: ctrl.workItems,
      showScrollbar: true,
      actions: [
        IconButton(
          onPressed: ctrl.createWorkItem,
          icon: Icon(
            DevOpsIcons.plus,
            size: 24,
          ),
        ),
      ],
      onResetFilters: ctrl.resetFilters,
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
          FilterMenu<Project>.bottomsheet(
            title: 'Project',
            values: ctrl.getProjects(ctrl.storageService),
            currentFilter: ctrl.projectFilter,
            onSelected: ctrl.filterByProject,
            formatLabel: (p) => p.name!,
            isDefaultFilter: ctrl.projectFilter == ctrl.projectAll,
          ),
          FilterMenu<String>(
            title: 'Status',
            values: WorkItemExt.allStates,
            currentFilter: ctrl.statusFilter,
            onSelected: ctrl.filterByStatus,
            isDefaultFilter: ctrl.statusFilter == ctrl._workItemStateAll,
          ),
          FilterMenu<WorkItemType>(
            title: 'Type',
            values: ctrl.allWorkItemTypes,
            formatLabel: (t) => t.name,
            currentFilter: ctrl.typeFilter,
            onSelected: ctrl.filterByType,
            isDefaultFilter: ctrl.typeFilter.name == 'All',
          ),
          FilterMenu<GraphUser>.bottomsheet(
            title: 'Assigned to',
            values: ctrl.getSortedUsers(ctrl.apiService),
            currentFilter: ctrl.userFilter,
            onSelected: ctrl.filterByUser,
            formatLabel: (u) => u.displayName!,
            isDefaultFilter: ctrl.userFilter == ctrl.userAll,
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
