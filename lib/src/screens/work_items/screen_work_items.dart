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
          FilterMenu<Project>(
            title: 'Project',
            values: ctrl.getProjects(ctrl.storageService),
            currentFilter: ctrl.projectFilter,
            onSelected: ctrl.filterByProject,
            formatLabel: (p) => p.name!,
            isDefaultFilter: ctrl.projectFilter == ctrl.projectAll,
            widgetBuilder: (p) => ProjectFilterWidget(project: p),
          ),
          FilterMenu<WorkItemState>(
            title: 'Status',
            values: ctrl.allWorkItemState,
            formatLabel: (t) => t.name,
            currentFilter: ctrl.statusFilter,
            onSelected: ctrl.filterByStatus,
            isDefaultFilter: ctrl.statusFilter == WorkItemState.all,
            widgetBuilder: (s) => WorkItemStateFilterWidget(state: s),
          ),
          FilterMenu<WorkItemType>(
            title: 'Type',
            values: ctrl.allWorkItemTypes,
            formatLabel: (t) => t.name,
            currentFilter: ctrl.typeFilter,
            onSelected: ctrl.filterByType,
            isDefaultFilter: ctrl.typeFilter.name == 'All',
            widgetBuilder: (t) => WorkItemTypeFilter(type: t),
          ),
          FilterMenu<GraphUser>(
            title: 'Assigned to',
            values: ctrl.getSortedUsers(ctrl.apiService),
            onSelected: ctrl.filterByUser,
            formatLabel: (u) => u.displayName ?? '',
            isDefaultFilter: ctrl.userFilter == ctrl.userAll,
            currentFilter: ctrl.userFilter,
            widgetBuilder: (u) => UserFilterWidget(user: u),
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
