library work_item_detail;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_item.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/alert_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/project_and_repo_chips.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_html_css/simple_html_css.dart';

part 'components_work_item_detail.dart';
part 'controller_work_item_detail.dart';
part 'parameters_work_item_detail.dart';
part 'screen_work_item_detail.dart';

class WorkItemDetailPage extends StatelessWidget {
  const WorkItemDetailPage();

  static const _smartphoneParameters = _WorkItemDetailParameters();
  static const _tabletParameters = _WorkItemDetailParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final storageService = StorageServiceInherited.of(context).storageService;
    final item = AppRouter.getWorkItemDetailArgs(context);
    final ctrl = _WorkItemDetailController(item: item, apiService: apiService, storageService: storageService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _WorkItemDetailScreen(ctrl, _smartphoneParameters)
          : _WorkItemDetailScreen(ctrl, _tabletParameters),
    );
  }
}
