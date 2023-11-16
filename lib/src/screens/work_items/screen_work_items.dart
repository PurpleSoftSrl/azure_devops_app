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
        _Actions(ctrl: ctrl),
      ],
      onResetFilters: ctrl.resetFilters,
      onEmpty: 'No work items found',
      header: () {
        final areasToShow = ctrl.getAreasToShow();
        final iterationsToShow = ctrl.getIterationsToShow();

        return FiltersRow(
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
              values: ctrl.allWorkItemStates,
              formatLabel: (t) => t.name,
              currentFilter: ctrl.statusFilter,
              onSelected: ctrl.filterByStatus,
              isDefaultFilter: ctrl.statusFilter == WorkItemState.all,
              widgetBuilder: (s) => WorkItemStateFilterWidget(state: s),
            ),
            WorkItemTypeFilterMenu(
              title: 'Type',
              values: ctrl.allWorkItemTypes,
              formatLabel: (t) =>
                  [null, 'system'].contains(t.customization) ? t.name : '${t.name} (${t.customization})',
              currentFilter: ctrl.typeFilter,
              onSelected: ctrl.filterByType,
              isDefaultFilter: ctrl.typeFilter.name == 'All',
              widgetBuilder: (t) => WorkItemTypeFilter(type: t),
            ),
            FilterMenu<GraphUser>(
              title: 'Assigned to',
              values: ctrl.getAssignees(),
              onSelected: ctrl.filterByUser,
              formatLabel: (u) => u.displayName ?? '',
              isDefaultFilter: ctrl.userFilter == ctrl.userAll,
              currentFilter: ctrl.userFilter,
              widgetBuilder: (u) => UserFilterWidget(user: u),
            ),
            if (areasToShow.isNotEmpty)
              FilterMenu<AreaOrIteration?>.custom(
                title: 'Area',
                formatLabel: (u) => u?.escapedAreaPath ?? '-',
                isDefaultFilter: ctrl.areaFilter == null,
                currentFilter: ctrl.areaFilter,
                body: AreaFilterBody(
                  currentFilter: ctrl.areaFilter,
                  areasToShow: areasToShow,
                  onTap: ctrl.filterByArea,
                ),
              ),
            if (iterationsToShow.isNotEmpty)
              FilterMenu<AreaOrIteration?>.custom(
                title: 'Iteration',
                formatLabel: (u) => u?.escapedIterationPath ?? '-',
                isDefaultFilter: ctrl.iterationFilter == null,
                currentFilter: ctrl.iterationFilter,
                body: ValueListenableBuilder(
                  valueListenable: ctrl.showActiveIterations,
                  builder: (ctx, showActive, _) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Show active'),
                          Checkbox(
                            value: showActive,
                            onChanged: (_) => ctrl.toggleShowActiveIterations(),
                          ),
                        ],
                      ),
                      Expanded(
                        child: AreaFilterBody(
                          currentFilter: ctrl.iterationFilter,
                          areasToShow: iterationsToShow,
                          onTap: ctrl.filterByIteration,
                          showActive: showActive,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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
