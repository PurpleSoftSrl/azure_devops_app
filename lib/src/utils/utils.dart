import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:purple_theme/purple_theme.dart';

/// Threshold that must be exceeded to show projects search field
const int projectsCountThreshold = 10;

void rebuildApp() {
  PurpleTheme.of(AppRouter.rootNavigator!.context).changeTheme(AppTheme.themeMode);
}
