library choose_projects;

import 'dart:async';
import 'dart:math';


import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/organization.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/search_field.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:flutter/material.dart';

part 'components_choose_projects.dart';
part 'controller_choose_projects.dart';
part 'parameters_choose_projects.dart';
part 'screen_choose_projects.dart';

class ChooseProjectsPage extends StatelessWidget {
  const ChooseProjectsPage();

  static const _smartphoneParameters = _ChooseProjectsParameters();
  static const _tabletParameters = _ChooseProjectsParameters();

  @override
  Widget build(BuildContext context) {
    final removeRoutes = AppRouter.getChooseProjectArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final storageService = StorageServiceInherited.of(context).storageService;
    final ctrl = _ChooseProjectsController(
      apiService: apiService,
      removeRoutes: removeRoutes,
      storageService: storageService,
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _ChooseProjectsScreen(ctrl, _smartphoneParameters)
          : _ChooseProjectsScreen(ctrl, _tabletParameters),
    );
  }
}
