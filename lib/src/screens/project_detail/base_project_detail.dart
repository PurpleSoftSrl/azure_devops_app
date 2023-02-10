library project_detail;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_result_extension.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/project_languages.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/team_member.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/pipeline_list_tile.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/pull_request_list_tile.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_project_detail.dart';
part 'controller_project_detail.dart';
part 'parameters_project_detail.dart';
part 'screen_project_detail.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage();

  static const _smartphoneParameters = _ProjectDetailParameters();
  static const _tabletParameters = _ProjectDetailParameters();

  @override
  Widget build(BuildContext context) {
    final project = AppRouter.getProjectDetailArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _ProjectDetailController(apiService: apiService, projectName: project);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _ProjectDetailScreen(ctrl, _smartphoneParameters)
          : _ProjectDetailScreen(ctrl, _tabletParameters),
    );
  }
}
