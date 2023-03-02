part of tabs;

class _TabsScreen extends StatelessWidget {
  const _TabsScreen(this.ctrl, this.parameters);

  final _TabsController ctrl;
  final _TabsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final canPop = ctrl.navPages[ctrl.page].key.currentState!.canPop();
        if (canPop) {
          final maybePop = await ctrl.navPages[ctrl.page].key.currentState!.maybePop();
          return !maybePop;
        }

        final shouldPop = await AppRouter.askBeforeClosingApp();
        return shouldPop;
      },
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: AppPageListenable.empty(
          onRefresh: ctrl.init,
          dispose: ctrl.dispose,
          builder: (_) => CupertinoTabScaffold(
            controller: ctrl.tabController,
            tabBar: CupertinoTabBar(
              backgroundColor: context.colorScheme.background,
              activeColor: context.colorScheme.onBackground,
              inactiveColor: context.colorScheme.onSecondary.withOpacity(.4),
              key: ctrl.tabKey,
              onTap: ctrl.goToTab,
              border: Border(top: BorderSide(color: context.colorScheme.secondaryContainer)),
              height: parameters.tabBarHeight,
              items: ctrl.navPages
                  .map(
                    (p) => BottomNavigationBarItem(
                      icon: ValueListenableBuilder<bool>(
                        valueListenable: ctrl.tabState[p.pageName]!,
                        builder: (_, isActive, __) => Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Icon(
                            p.icon,
                            size: parameters.tabIconHeight,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            tabBuilder: (_, i) => CupertinoTabView(
              builder: (_) => Navigator(
                key: ctrl.navPages[i].key,
                observers: [
                  HeroController(),
                  SentryNavigatorObserver(),
                ],
                onGenerateRoute: (route) => MaterialPageRoute(
                  builder: (_) => route.name == '/'
                      ? AppRouter.routes[ctrl.navPages[i].pageName]!(_)
                      : AppRouter.routes[route.name!]!(_),
                  settings: route,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
