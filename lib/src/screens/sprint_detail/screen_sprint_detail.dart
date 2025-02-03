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
        builder: (_) => BoardWidget(
          maxHeight: constraints.maxHeight,
          pageController: ctrl.pageController,
          columnItems: ctrl.columnItems,
          onTapItem: ctrl.goToDetail,
        ),
      ),
    );
  }
}
