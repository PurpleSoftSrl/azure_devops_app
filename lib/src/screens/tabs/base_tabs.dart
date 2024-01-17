library tabs;

import 'package:azure_devops/main.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'components_tabs.dart';
part 'controller_tabs.dart';
part 'parameters_tabs.dart';
part 'screen_tabs.dart';

class TabsPage extends StatelessWidget {
  const TabsPage();

  static const _smartphoneParameters = _TabsParameters(tabBarHeight: 50);
  static const _tabletParameters = _TabsParameters(tabBarHeight: 80, tabIconHeight: 40);

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      initState: _TabsController._,
      smartphone: (ctrl) => _TabsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _TabsScreen(ctrl, _tabletParameters),
    );
  }
}
