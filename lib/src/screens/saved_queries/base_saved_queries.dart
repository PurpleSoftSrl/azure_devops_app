library saved_queries;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/saved_query.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_saved_queries.dart';
part 'controller_saved_queries.dart';
part 'screen_saved_queries.dart';

typedef _SavedQueriesParameters = ();

class SavedQueriesPage extends StatelessWidget {
  const SavedQueriesPage();

  static const _SavedQueriesParameters _smartphoneParameters = ();
  static const _SavedQueriesParameters _tabletParameters = ();

  @override
  Widget build(BuildContext context) {
    final args = AppRouter.getSavedQueriesArgs(context);
    final api = AzureApiServiceInherited.of(context).apiService;
    final ads = context.adsService;
    return AppBasePage(
      initState: () => _SavedQueriesController._(args, api, ads),
      smartphone: (ctrl) => _SavedQueriesScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _SavedQueriesScreen(ctrl, _tabletParameters),
    );
  }
}
