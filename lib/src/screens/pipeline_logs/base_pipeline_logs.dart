library pipeline_logs;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:flutter/material.dart';

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
    return AppBasePage(
      initState: () => _PipelineLogsController._(apiService, args),
      smartphone: (ctrl) => _PipelineLogsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _PipelineLogsScreen(ctrl, _tabletParameters),
    );
  }
}
