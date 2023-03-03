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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                item.workItemTypeIcon,
              ],
            ),
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 20,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge,
                  ),
                ),
                Text(
                  item.state,
                  style: subtitleStyle.copyWith(color: item.stateColor),
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
                    Expanded(
                      child: Text(
                        item.teamProject,
                        style: subtitleStyle,
                      ),
                    ),
                    Text(
                      item.changedDate.minutesAgo,
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
