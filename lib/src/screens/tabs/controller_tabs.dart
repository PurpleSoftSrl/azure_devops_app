part of tabs;

class _TabsController {
  _TabsController._();

  late List<_TabPage> navPages = _getTabPages();

  final GlobalKey<NavigatorState> tabKey = GlobalKey<NavigatorState>(debugLabel: 'tab_bar_key');

  int page = 0;
  int previousIndex = 0;

  final tabController = CupertinoTabController();

  late final tabState = <String, ValueNotifier<bool>>{
    for (final p in navPages) p.pageName: ValueNotifier(navPages.indexOf(p) == 0),
  };

  Future<void> init() async {
    navPages = _getTabPages();

    AppRouter.tabKeys = navPages.map((e) => e.key).toList();
    AppRouter.index = 0;
  }

  void popAll(GlobalKey<NavigatorState> key) {
    final currentKey = key;
    return currentKey.currentState?.popUntil((r) => r.isFirst);
  }

  void switchTab(int index) {
    previousIndex = page;

    if (page == index) popAll(navPages[index].key);
    page = index;
    AppRouter.index = index;

    for (var i = 0; i < navPages.length; i++) {
      if (i == index) continue;

      tabState[navPages[i].pageName]!.value = false;
    }

    tabState[navPages[index].pageName]!.value = true;
  }

  void goToTab(int index) {
    switchTab(index);
  }

  List<_TabPage> _getTabPages() {
    return <_TabPage>[
      _TabPage(
        pageName: AppRouter.home,
        icon: DevOpsIcons.home,
        key: GlobalKey<NavigatorState>(),
      ),
      _TabPage(
        pageName: AppRouter.profile,
        icon: DevOpsIcons.profile,
        key: GlobalKey<NavigatorState>(),
      ),
      _TabPage(
        pageName: AppRouter.settings,
        icon: DevOpsIcons.settings,
        key: GlobalKey<NavigatorState>(),
      ),
    ];
  }

  String? getRouteName(RouteSettings settings, int i) {
    if (settings.name == null) return navPages[previousIndex].pageName;
    if (settings.name == '/') return navPages[i].pageName;
    return settings.name;
  }

  RouteSettings? getRouteSettingsName(RouteSettings? settings, int i) {
    if (settings?.name == null) return null;
    final routeName = getRouteName(settings!, i);
    if (routeName == null) return null;
    return RouteSettings(name: routeName);
  }

  void popTab({required bool didPop}) {
    if (didPop) return;

    final canPop = navPages[page].key.currentState!.canPop();

    if (canPop) return;

    AppRouter.askBeforeClosingApp(didPop: didPop);
  }
}

class _TabPage {
  _TabPage({
    required this.pageName,
    required this.icon,
    required this.key,
  });

  final String pageName;
  final IconData icon;
  final GlobalKey<NavigatorState> key;
}
