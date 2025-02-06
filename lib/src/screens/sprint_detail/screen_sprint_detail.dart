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
        actions: [
          IconButton(
            icon: const Icon(DevOpsIcons.plus),
            onPressed: ctrl.addNewItem,
          ),
        ],
        builder: (_) => DefaultTabController(
          length: ctrl.columnItems.length,
          child: Builder(
            builder: (ctx) => BoardWidget(
              maxHeight: constraints.maxHeight,
              tabController: DefaultTabController.of(ctx),
              columnItems: ctrl.columnItems,
              onTapItem: ctrl.goToDetail,
            ),
          ),
        ),
      ),
    );
  }
}
