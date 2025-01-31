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
        builder: (boardWithItems) => SizedBox(
          height: constraints.maxHeight,
          child: PageView(
            controller: ctrl.pageController,
            children: boardWithItems.board.columns
                .map(
                  (c) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colorScheme.primary,
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(c.name),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            ...boardWithItems.items.where((i) => i.fields.boardColumn == c.name).map(
                                  (i) => WorkItemListTile(
                                    item: i,
                                    onTap: () => ctrl.goToDetail(i),
                                    isLast: false,
                                  ),
                                ),
                            const SizedBox(
                              height: 200,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
