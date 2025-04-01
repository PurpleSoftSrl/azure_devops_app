part of sprint_detail;

class _Actions extends StatelessWidget {
  const _Actions({required this.ctrl});

  final _SprintDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: DevOpsAnimatedSearchField(
        isSearching: ctrl.isSearching,
        onChanged: ctrl._searchWorkItem,
        onResetSearch: ctrl.resetSearch,
        hint: 'Search by id or title',
        margin: const EdgeInsets.only(left: 56, right: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchButton(
              isSearching: ctrl.isSearching,
            ),
            IconButton(
              icon: const Icon(DevOpsIcons.plus),
              onPressed: ctrl.addNewItem,
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.ctrl});

  final _SprintDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ctrl.sprintWithItems,
      builder: (_, sprint, __) => FiltersRow(
        resetFilters: ctrl.resetFilters,
        filters: sprint == null
            ? const []
            : [
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
    );
  }
}
