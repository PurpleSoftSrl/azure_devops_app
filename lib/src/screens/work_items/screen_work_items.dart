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
            if (ctrl.statesFilter.isEmpty)
              FilterMenu<WorkItemStateCategory>.multiple(
                title: 'Categories',
                values: WorkItemStateCategory.values.sorted((a, b) => a.sortOrder.compareTo(b.sortOrder)).toList(),
                formatLabel: (t) => t.stringValue,
                currentFilters: ctrl.stateCategoriesFilter,
                onSelectedMultiple: ctrl.filterByStateCategory,
                isDefaultFilter: ctrl.isDefaultStateCategoryFilter,
                widgetBuilder: (s) => WorkItemStateCategoryFilterWidget(category: s),
              ),
            if (ctrl.stateCategoriesFilter.isEmpty)
              FilterMenu<WorkItemState>.multiple(
                title: 'States',
                values: ctrl.allWorkItemStates,
                formatLabel: (t) => t.name,
                currentFilters: ctrl.statesFilter,
                onSelectedMultiple: ctrl.filterByStates,
                isDefaultFilter: ctrl.isDefaultStateFilter,
                widgetBuilder: (s) => WorkItemStateFilterWidget(state: s),
              ),
            WorkItemTypeFilterMenu.multiple(
              title: 'Types',
              values: ctrl.allWorkItemTypes,
              formatLabel: (t) =>
                  [null, 'system'].contains(t.customization) ? t.name : '${t.name} (${t.customization})',
              currentFilters: ctrl.typesFilter,
              onSelectedMultiple: ctrl.filterByTypes,
              isDefaultFilter: ctrl.typesFilter.isEmpty,
              widgetBuilder: (t) => WorkItemTypeFilter(type: t),
            ),
            FilterMenu<GraphUser>.multiple(
              title: 'Assigned to',
              values: ctrl.getAssignees(),
              onSelectedMultiple: ctrl.filterByUsers,
              formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.apiService),
              isDefaultFilter: ctrl.isDefaultUsersFilter,
              currentFilters: ctrl.usersFilter,
              widgetBuilder: (u) => UserFilterWidget(user: u),
              onSearchChanged: ctrl.hasManyUsers(ctrl.apiService) ? ctrl.searchAssignee : null,
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
                  builder: (_, showActive, __) => Column(
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
