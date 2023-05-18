library work_items;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/work_item_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_item_type.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_work_items.dart';
part 'controller_work_items.dart';
part 'parameters_work_items.dart';
part 'screen_work_items.dart';

class WorkItemsPage extends StatelessWidget {
  const WorkItemsPage();

  static const _smartphoneParameters = _WorkItemsParameters();
  static const _tabletParameters = _WorkItemsParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final storageService = StorageServiceInherited.of(context).storageService;
    final project = AppRouter.getWorkItemsArgs(context);
    final ctrl = _WorkItemsController(
      apiService: apiService,
      storageService: storageService,
      project: project,
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _WorkItemsScreen(ctrl, _smartphoneParameters)
          : _WorkItemsScreen(ctrl, _tabletParameters),
    );
  }
}
