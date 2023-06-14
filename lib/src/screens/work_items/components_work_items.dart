part of work_items;

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
                      ),
                    ),
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
