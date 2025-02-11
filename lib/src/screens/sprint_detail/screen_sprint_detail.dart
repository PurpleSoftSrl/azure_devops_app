part of sprint_detail;

class _SprintDetailScreen extends StatelessWidget {
  const _SprintDetailScreen(this.ctrl, this.parameters);

  final _SprintDetailController ctrl;
  final _SprintDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AppPage(
        init: ctrl.init,
        title: ctrl.args.sprintName,
        notifier: ctrl.sprintWithItems,
        padding: EdgeInsets.zero,
        actions: [
          IconButton(
            icon: const Icon(DevOpsIcons.plus),
            onPressed: ctrl.addNewItem,
          ),
        ],
        header: () => FiltersRow(
          resetFilters: ctrl.resetFilters,
          filters: [
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
              formatLabel: (u) => ctrl.getFormattedUser(u, ctrl.api),
              isDefaultFilter: ctrl.isDefaultUsersFilter,
              currentFilters: ctrl.usersFilter,
              widgetBuilder: (u) => UserFilterWidget(user: u),
              onSearchChanged: ctrl.hasManyUsers(ctrl.api) ? ctrl.searchAssignee : null,
            ),
          ],
        ),
        builder: (_) => DefaultTabController(
          length: ctrl.columnItems.length,
          child: Builder(
            builder: (ctx) => BoardWidget(
              maxHeight: constraints.maxHeight,
              tabController: DefaultTabController.of(ctx),
              columnItems: ctrl.columnItems,
              onTapItem: ctrl.goToDetail,
            ),
          ),
        ),
      ),
    );
  }
}
