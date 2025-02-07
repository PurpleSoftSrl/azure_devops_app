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
    final api = context.api;
    final wt = api.workItemTypes[item.fields.systemTeamProject]
        ?.firstWhereOrNull((t) => t.name == item.fields.systemWorkItemType);
    final state = api.workItemStates[item.fields.systemTeamProject]?[item.fields.systemWorkItemType]
        ?.firstWhereOrNull((t) => t.name == item.fields.systemState);

    final hasAssignee = item.fields.systemAssignedTo?.descriptor != null;
    final hasComments = (item.fields.systemCommentCount ?? 0) > 0;

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
                    color: state == null ? null : Color(int.parse(state.color, radix: 16)).withValues(alpha: 1),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Text(
                            '#${item.id}',
                            style: subtitleStyle,
                          ),
                          Text(
                            ' in ',
                            style: subtitleStyle.copyWith(color: context.colorScheme.onSecondary),
                          ),
                          Flexible(
                            child: Text(
                              item.fields.systemTeamProject,
                              style: subtitleStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasComments) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.colorScheme.surface,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.forum_outlined,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    item.fields.systemCommentCount!.toString(),
                                    style: subtitleStyle.copyWith(height: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (hasAssignee) ...[
                            const SizedBox(width: 8),
                            MemberAvatar(
                              userDescriptor: item.fields.systemAssignedTo?.descriptor,
                              radius: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
            AppLayoutBuilder(
              smartphone: const Divider(height: 1, thickness: 1),
              tablet: const Divider(height: 5, thickness: 1),
            ),
        ],
      ),
    );
  }
}
