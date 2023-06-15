library create_or_edit_work_item;

import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

part 'components_create_or_edit_work_item.dart';
part 'controller_create_or_edit_work_item.dart';
part 'parameters_create_or_edit_work_item.dart';
part 'screen_create_or_edit_work_item.dart';

class CreateOrEditWorkItemPage extends StatelessWidget {
  const CreateOrEditWorkItemPage();

  static const _smartphoneParameters = _CreateOrEditWorkItemParameters();
  static const _tabletParameters = _CreateOrEditWorkItemParameters();

  @override
  Widget build(BuildContext context) {
    final args = AppRouter.getCreateOrEditWorkItemArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final storageService = StorageServiceInherited.of(context).storageService;
    final ctrl = _CreateOrEditWorkItemController(apiService: apiService, args: args, storageService: storageService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 600
          ? _CreateOrEditWorkItemScreen(ctrl, _smartphoneParameters)
          : _CreateOrEditWorkItemScreen(ctrl, _tabletParameters),
    );
  }
}
