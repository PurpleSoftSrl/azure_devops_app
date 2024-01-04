library pull_requests;

import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/filters_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/pull_request_list_tile.dart';
import 'package:azure_devops/src/widgets/search_field.dart';
import 'package:flutter/material.dart';

part 'components_pull_requests.dart';
part 'controller_pull_requests.dart';
part 'parameters_pull_requests.dart';
part 'screen_pull_requests.dart';

class PullRequestsPage extends StatelessWidget {
  const PullRequestsPage();

  static const _smartphoneParameters = _PullRequestsParameters();
  static const _tabletParameters = _PullRequestsParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final storageService = StorageServiceInherited.of(context).storageService;
    final args = AppRouter.getPullRequestsArgs(context);
    final ctrl = _PullRequestsController(
      apiService: apiService,
      storageService: storageService,
      args: args,
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _PullRequestsScreen(ctrl, _smartphoneParameters)
          : _PullRequestsScreen(ctrl, _tabletParameters),
    );
  }
}
