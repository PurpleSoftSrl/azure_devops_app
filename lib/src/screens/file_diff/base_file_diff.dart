library file_diff;

import 'dart:math';

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/mixins/pull_request_mixin.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/file_diff.dart';
import 'package:azure_devops/src/models/pull_request_with_details.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/add_comment_field.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/pull_request_comment_card.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

part 'components_file_diff.dart';
part 'controller_file_diff.dart';
part 'parameters_file_diff.dart';
part 'screen_file_diff.dart';

class FileDiffPage extends StatelessWidget {
  const FileDiffPage();

  static const _smartphoneParameters = _FileDiffParameters();
  static const _tabletParameters = _FileDiffParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final args = AppRouter.getCommitDiffArgs(context);
    final ctrl = _FileDiffController(apiService: apiService, args: args);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _FileDiffScreen(ctrl, _smartphoneParameters)
          : _FileDiffScreen(ctrl, _tabletParameters),
    );
  }
}
