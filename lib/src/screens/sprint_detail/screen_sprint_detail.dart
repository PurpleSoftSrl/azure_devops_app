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
        builder: (_) => SizedBox(
          height: constraints.maxHeight,
          child: PageView(
            controller: ctrl.pageController,
            children: ctrl.columnItems.entries.map(
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
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 200),
                        children: columnItems
                            .map(
                              (i) => WorkItemListTile(
                                item: i,
                                onTap: () => ctrl.goToDetail(i),
                                isLast: false,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
