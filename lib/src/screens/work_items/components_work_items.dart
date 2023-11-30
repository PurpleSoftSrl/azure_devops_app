part of work_items;

class _Actions extends StatelessWidget {
  const _Actions({required this.ctrl});

  final _WorkItemsController ctrl;

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
              onPressed: ctrl.createWorkItem,
              icon: Icon(
                DevOpsIcons.plus,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkItemListTile extends StatelessWidget {
  const _WorkItemListTile({
    required this.item,
    required this.onTap,
    required this.isLast,
  });

  final VoidCallback onTap;
  final WorkItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodySmall!;
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final wt = apiService.workItemTypes[item.fields.systemTeamProject]
        ?.firstWhereOrNull((t) => t.name == item.fields.systemWorkItemType);
    final state = apiService.workItemStates[item.fields.systemTeamProject]?[item.fields.systemWorkItemType]
        ?.firstWhereOrNull((t) => t.name == item.fields.systemState);

    return InkWell(
      onTap: onTap,
      key: ValueKey('work_item_${item.id}'),
      child: Column(
        children: [
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [WorkItemTypeIcon(type: wt)],
            ),
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 20,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.fields.systemTitle,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.fields.systemState,
                  style: subtitleStyle.copyWith(
                    color: state == null ? null : Color(int.parse(state.color, radix: 16)).withOpacity(1),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text(
                      '#${item.id}',
                      style: subtitleStyle,
                    ),
                    Text(
                      ' in ',
                      style: subtitleStyle.copyWith(color: context.colorScheme.onSecondary),
                    ),
                    Expanded(
                      child: Text(
                        item.fields.systemTeamProject,
                        style: subtitleStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.fields.systemChangedDate.minutesAgo,
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            LayoutBuilder(
              builder: (_, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
                  ? const Divider(
                      height: 1,
                      thickness: 1,
                    )
                  : const Divider(
                      height: 5,
                      thickness: 1,
                    ),
            ),
        ],
      ),
    );
  }
}
