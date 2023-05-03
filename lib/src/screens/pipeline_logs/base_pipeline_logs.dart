library pipeline_logs;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

part 'components_pipeline_logs.dart';
part 'controller_pipeline_logs.dart';
part 'parameters_pipeline_logs.dart';
part 'screen_pipeline_logs.dart';

class PipelineLogsPage extends StatelessWidget {
  const PipelineLogsPage();

  static const _smartphoneParameters = _PipelineLogsParameters();
  static const _tabletParameters = _PipelineLogsParameters();

  @override
  Widget build(BuildContext context) {
    final args = AppRouter.getPipelineLogsArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _PipelineLogsController(apiService: apiService, args: args);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 600
          ? _PipelineLogsScreen(ctrl, _smartphoneParameters)
          : _PipelineLogsScreen(ctrl, _tabletParameters),
    );
  }
}
