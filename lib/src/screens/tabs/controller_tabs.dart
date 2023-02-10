part of tabs;

class _TabsController {
  factory _TabsController() {
    return instance ??= _TabsController._();
  }

  _TabsController._();

  static _TabsController? instance;

  List<_NavPage> navPages = <_NavPage>[
    _NavPage(
      pageName: AppRouter.home,
      icon: DevOpsIcons.home,
      key: GlobalKey<NavigatorState>(),
    ),
    _NavPage(
      pageName: AppRouter.profile,
      icon: DevOpsIcons.profile,
      key: GlobalKey<NavigatorState>(),
    ),
    _NavPage(
      pageName: AppRouter.settings,
      icon: DevOpsIcons.settings,
      key: GlobalKey<NavigatorState>(),
    ),
  ];

  final GlobalKey<NavigatorState> tabKey = GlobalKey<NavigatorState>(debugLabel: 'tab_bar_key');

  int page = 0;

  final tabController = CupertinoTabController();

  late final tabState = <String, ValueNotifier<bool>>{
    for (final p in navPages) p.pageName: ValueNotifier(navPages.indexOf(p) == 0),
  };

  void init() {
    navPages = <_NavPage>[
      _NavPage(
        pageName: AppRouter.home,
        icon: DevOpsIcons.home,
        key: GlobalKey<NavigatorState>(),
      ),
      _NavPage(
        pageName: AppRouter.profile,
        icon: DevOpsIcons.profile,
        key: GlobalKey<NavigatorState>(),
      ),
      _NavPage(
        pageName: AppRouter.settings,
        icon: DevOpsIcons.settings,
        key: GlobalKey<NavigatorState>(),
      ),
    ];

    AppRouter.setTabKeys(navPages.map((e) => e.key).toList());
    AppRouter.index = 0;
  }

  void dispose() {
    instance = null;
  }

  void popAll(GlobalKey<NavigatorState> key) {
    final currentKey = key;
    return currentKey.currentState?.popUntil((r) => r.isFirst);
  }

  void switchTab(int index) {
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
}

class _NavPage {
  _NavPage({
    required this.pageName,
    required this.icon,
    required this.key,
  });

  final String pageName;
  final IconData icon;
  final GlobalKey<NavigatorState> key;
}
