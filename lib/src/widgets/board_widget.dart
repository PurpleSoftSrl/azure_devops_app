import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/board.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/work_item_tile.dart';
import 'package:flutter/material.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({
    required this.maxHeight,
    required this.pageController,
    required this.columnItems,
    required this.onTapItem,
    this.actions,
  });

  final double maxHeight;
  final PageController pageController;
  final Map<BoardColumn, List<WorkItem>> columnItems;
  final void Function(WorkItem) onTapItem;
  final List<PopupItem> Function(WorkItem)? actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      child: PageView(
        controller: pageController,
        children: columnItems.entries.map(
          (col) {
            final column = col.key;
            final columnItems = col.value;
            final columnItemCount = col.value.length;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(column.name),
                          const SizedBox(width: 5),
                          if (columnItemCount > 0) ...[
                            Text('$columnItemCount'),
                            if (column.itemLimit > 0) Text('/${column.itemLimit}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: switch (columnItems) {
                    [] => Center(child: Text('No ${column.name} items')),
                    _ => ListView(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 200),
                        children: columnItems
                            .map(
                              (i) => WorkItemListTile(
                                item: i,
                                onTap: () => onTapItem(i),
                                isLast: false,
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
    );
  }
}
