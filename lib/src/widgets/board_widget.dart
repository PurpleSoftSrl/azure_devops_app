import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/models/board.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/work_item_type_icon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({
    required this.maxHeight,
    required this.columnItems,
    required this.onTapItem,
    this.actions,
    required this.tabController,
  });

  final double maxHeight;
  final TabController tabController;
  final Map<BoardColumn, List<WorkItem>> columnItems;
  final void Function(WorkItem) onTapItem;
  final List<PopupItem> Function(WorkItem)? actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            dividerColor: Colors.transparent,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            indicatorColor: context.colorScheme.primary,
            labelColor: context.colorScheme.primary,
            labelStyle: context.textTheme.titleMedium,
            unselectedLabelColor: context.colorScheme.onSecondary,
            unselectedLabelStyle: context.textTheme.titleMedium,
            labelPadding: EdgeInsets.symmetric(horizontal: 48),
            indicatorPadding: EdgeInsets.fromLTRB(10, 45, 10, 0),
            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: columnItems.keys.map((c) {
              final columnItemCount = columnItems[c]!.length;

              var label = c.name;
              if (columnItemCount > 0) {
                label += ' $columnItemCount';
                if (c.itemLimit > 0) label += '/${c.itemLimit}';
              }

              return Tab(text: label);
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: columnItems.entries.map(
                (col) {
                  final columnName = col.key.name;
                  final columnItems = col.value;
                  return Column(
                    children: [
                      Expanded(
                        child: switch (columnItems) {
                          [] => Center(child: Text('No $columnName items')),
                          _ => ListView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
                              children: columnItems
                                  .map(
                                    (i) => _WorkItemCard(
                                      item: i,
                                      onTap: onTapItem,
                                      actions: actions != null ? () => actions!(i) : null,
                                    ),
                                  )
                                  .toList(),
                            ),
                        },
                      ),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkItemCard extends StatelessWidget {
  const _WorkItemCard({required this.item, required this.onTap, this.actions});

  final WorkItem item;
  final void Function(WorkItem) onTap;
  final List<PopupItem> Function()? actions;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodySmall!;
    final apiService = context.api;
    final wt = apiService.workItemTypes[item.fields.systemTeamProject]
        ?.firstWhereOrNull((t) => t.name == item.fields.systemWorkItemType);

    final hasAssignee = item.fields.systemAssignedTo?.descriptor != null;
    final hasComments = (item.fields.systemCommentCount ?? 0) > 0;

    final hasTags = item.fields.systemTags != null && item.fields.systemTags!.isNotEmpty;
    final tags = item.fields.systemTags?.split(';') ?? [];

    return InkWell(
      onTap: () => onTap(item),
      key: ValueKey('work_item_${item.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: wt?.color != null
                  ? Color(int.parse(wt!.color!, radix: 16)).withValues(alpha: 1)
                  : context.colorScheme.onSurface,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  '${item.id}',
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 16,
                ),
                WorkItemTypeIcon(
                  type: wt,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fields.systemTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      if (hasAssignee) ...[
                        MemberAvatar(
                          userDescriptor: item.fields.systemAssignedTo?.descriptor,
                          radius: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.fields.systemAssignedTo!.displayName!,
                          style: context.textTheme.labelSmall!.copyWith(height: 1),
                        ),
                      ],
                      const SizedBox(
                        width: 16,
                      ),
                      if (hasComments) ...[
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
                                DevOpsIcons.comments,
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
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (hasTags) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags.take(10))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              tag.trim(),
                              style: context.textTheme.labelSmall!
                                  .copyWith(height: 1, color: context.colorScheme.onSecondary),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (actions != null) ...[
                  const SizedBox(width: 8),
                  DevOpsPopupMenu(
                    tooltip: 'Work item board actions',
                    items: actions!,
                  ),
                ],
                const SizedBox(
                  height: 4,
                ),
                Text(
                  item.fields.systemChangedDate.minutesAgo,
                  style: subtitleStyle,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  item.fields.systemState,
                  style: subtitleStyle.copyWith(color: context.colorScheme.onSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
