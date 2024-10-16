library work_item_detail;

import 'dart:async';
import 'dart:io';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/string_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/processes.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_item_fields.dart';
import 'package:azure_devops/src/models/work_item_updates.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/add_comment_field.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/html_widget.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/project_and_repo_chips.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:azure_devops/src/widgets/work_item_type_icon.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    final args = AppRouter.getWorkItemDetailArgs(context);
    return AppBasePage(
      initState: () => _WorkItemDetailController._(args, apiService, storageService),
      smartphone: (ctrl) => _WorkItemDetailScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _WorkItemDetailScreen(ctrl, _tabletParameters),
    );
  }
}
