part of pull_request_detail;

class _PullRequestDetailScreen extends StatelessWidget {
  const _PullRequestDetailScreen(this.ctrl, this.parameters);

  final _PullRequestDetailController ctrl;
  final _PullRequestDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        DefaultTabController(
          length: 3,
          child: Builder(
            builder: (ctx) => AppPage<PullRequestWithDetails?>(
              init: ctrl.init,
              dispose: ctrl.dispose,
              title: 'Pull request',
              notifier: ctrl.prDetail,
              header: () => TabBar(
                onTap: (i) => ctrl.selectPage(i, DefaultTabController.of(ctx)),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 24),
                labelPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                overlayColor: MaterialStatePropertyAll(Colors.transparent),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: context.colorScheme.secondary,
                labelColor: context.colorScheme.secondary,
                unselectedLabelColor: context.colorScheme.onBackground.withOpacity(.8),
                labelStyle: context.textTheme.labelLarge,
                unselectedLabelStyle: context.textTheme.labelLarge,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Files'),
                  Tab(text: 'Commits'),
                ],
              ),
              actions: [
                ValueListenableBuilder(
                  valueListenable: ctrl.prDetail,
                  builder: (_, pr, __) => pr == null || pr.isError ? const SizedBox() : _PullRequestActions(ctrl: ctrl),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
              builder: (prWithDetails) => ValueListenableBuilder(
                valueListenable: ctrl.visiblePage,
                builder: (context, visiblePage, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _PageTabs(
                      ctrl: ctrl,
                      visiblePage: visiblePage,
                      prWithDetails: prWithDetails!,
                    ),
                    ValueListenableBuilder(
                      valueListenable: ctrl.showCommentField,
                      builder: (_, value, __) => SizedBox(
                        height: value ? 100 : 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AddCommentField(
          isVisible: ctrl.showCommentField,
          onTap: ctrl.addComment,
        ),
      ],
    );
  }
}
