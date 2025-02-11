part of board_detail;

class _BoardDetailScreen extends StatelessWidget {
  const _BoardDetailScreen(this.ctrl, this.parameters);

  final _BoardDetailController ctrl;
  final _BoardDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AppPage(
        init: ctrl.init,
        title: ctrl.args.boardId,
        notifier: ctrl.boardWithItems,
        padding: EdgeInsets.zero,
        actions: [
          _Actions(ctrl: ctrl),
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
              columnItems: ctrl.columnItems,
              onTapItem: ctrl.goToDetail,
              tabController: DefaultTabController.of(ctx),
              actions: (item) => [
                PopupItem(text: 'Edit', onTap: () => ctrl.editItem(item)),
                PopupItem(text: 'Move to column', onTap: () => ctrl.moveToColumn(item)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
