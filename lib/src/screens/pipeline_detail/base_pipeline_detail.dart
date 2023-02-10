library pipeline_detail;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/duration_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_result_extension.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/timeline.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/alert_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/pipeline_in_progress_animated_icon.dart';
import 'package:azure_devops/src/widgets/project_and_repo_chips.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

part 'components_pipeline_detail.dart';
part 'controller_pipeline_detail.dart';
part 'parameters_pipeline_detail.dart';
part 'screen_pipeline_detail.dart';

class PipelineDetailPage extends StatelessWidget {
  const PipelineDetailPage();

  static const _smartphoneParameters = _PipelineDetailParameters();
  static const _tabletParameters = _PipelineDetailParameters();

  @override
  Widget build(BuildContext context) {
    final pipeline = AppRouter.getPipelineDetailArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _PipelineDetailController(pipeline: pipeline, apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _PipelineDetailScreen(ctrl, _smartphoneParameters)
          : _PipelineDetailScreen(ctrl, _tabletParameters),
    );
  }
}
