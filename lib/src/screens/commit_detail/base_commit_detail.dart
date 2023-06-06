library commit_detail;

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/commit_detail.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/project_and_repo_chips.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

part 'components_commit_detail.dart';
part 'controller_commit_detail.dart';
part 'parameters_commit_detail.dart';
part 'screen_commit_detail.dart';

class CommitDetailPage extends StatelessWidget {
  const CommitDetailPage();

  static const _smartphoneParameters = _CommitDetailParameters();
  static const _tabletParameters = _CommitDetailParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final args = AppRouter.getCommitDetailArgs(context);
    final ctrl = _CommitDetailController(args: args, apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _CommitDetailScreen(ctrl, _smartphoneParameters)
          : _CommitDetailScreen(ctrl, _tabletParameters),
    );
  }
}
