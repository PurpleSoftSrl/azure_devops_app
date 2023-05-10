library file_diff;

import 'dart:math';

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/file_diff.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:flutter/material.dart';

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
      builder: (context, constraints) => constraints.maxWidth < 600
          ? _FileDiffScreen(ctrl, _smartphoneParameters)
          : _FileDiffScreen(ctrl, _tabletParameters),
    );
  }
}
