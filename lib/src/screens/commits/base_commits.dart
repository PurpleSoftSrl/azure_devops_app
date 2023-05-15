library commits;

import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/commit_list_tile.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_commits.dart';
part 'controller_commits.dart';
part 'parameters_commits.dart';
part 'screen_commits.dart';

class CommitsPage extends StatelessWidget {
  const CommitsPage();

  static const _smartphoneParameters = _CommitsParameters();
  static const _tabletParameters = _CommitsParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final storageService = StorageServiceInherited.of(context).storageService;
    final project = AppRouter.getCommitsArgs(context);
    final ctrl = _CommitsController(
      apiService: apiService,
      storageService: storageService,
      project: project,
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _CommitsScreen(ctrl, _smartphoneParameters)
          : _CommitsScreen(ctrl, _tabletParameters),
    );
  }
}
