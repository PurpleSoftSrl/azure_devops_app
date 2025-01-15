library create_or_edit_work_item;

import 'dart:async';
import 'dart:convert';

import 'package:azure_devops/src/extensions/area_or_iteration_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/string_extension.dart';
import 'package:azure_devops/src/extensions/work_item_relation_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/areas_and_iterations.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_item_fields.dart';
import 'package:azure_devops/src/models/work_item_link_types.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/rules_checker.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/html_editor.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/work_item_area_filter.dart';
import 'package:azure_devops/src/widgets/work_item_type_icon.dart';
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
    final ads = context.adsService;
    return AppBasePage(
      initState: () => _CreateOrEditWorkItemController._(apiService, args, storageService, ads),
      smartphone: (ctrl) => _CreateOrEditWorkItemScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _CreateOrEditWorkItemScreen(ctrl, _tabletParameters),
    );
  }
}
