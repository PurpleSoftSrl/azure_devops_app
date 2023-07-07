library pull_request_detail;

import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/pull_request_extension.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/commit.dart' as c;
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/pull_request_with_details.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/project_and_repo_chips.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'components_pull_request_detail.dart';
part 'controller_pull_request_detail.dart';
part 'parameters_pull_request_detail.dart';
part 'screen_pull_request_detail.dart';

class PullRequestDetailPage extends StatelessWidget {
  const PullRequestDetailPage();

  static const _smartphoneParameters = _PullRequestDetailParameters();
  static const _tabletParameters = _PullRequestDetailParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final args = AppRouter.getPullRequestDetailArgs(context);
    final ctrl = _PullRequestDetailController(args: args, apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _PullRequestDetailScreen(ctrl, _smartphoneParameters)
          : _PullRequestDetailScreen(ctrl, _tabletParameters),
    );
  }
}
