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
        title: ctrl.args.boardName,
        notifier: ctrl.boardWithItems,
        padding: EdgeInsets.zero,
        actions: [
          _Actions(ctrl: ctrl),
        ],
        header: () => _Filters(ctrl: ctrl),
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
