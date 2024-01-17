library work_items;

import 'package:azure_devops/src/extensions/area_or_iteration_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/areas_and_iterations.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/filters_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/search_field.dart';
import 'package:azure_devops/src/widgets/shortcut_label.dart';
import 'package:azure_devops/src/widgets/work_item_area_filter.dart';
import 'package:azure_devops/src/widgets/work_item_type_icon.dart';
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
    final args = AppRouter.getWorkItemsArgs(context);
    return AppBasePage(
      initState: () => _WorkItemsController._(apiService, storageService, args),
      smartphone: (ctrl) => _WorkItemsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _WorkItemsScreen(ctrl, _tabletParameters),
    );
  }
}
