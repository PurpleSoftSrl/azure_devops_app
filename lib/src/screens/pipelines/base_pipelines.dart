library pipelines;

import 'package:azure_devops/src/extensions/pipeline_result_extension.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/pipeline_list_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_pipelines.dart';
part 'controller_pipelines.dart';
part 'parameters_pipelines.dart';
part 'screen_pipelines.dart';

class PipelinesPage extends StatelessWidget {
  const PipelinesPage();

  static const _smartphoneParameters = _PipelinesParameters();
  static const _tabletParameters = _PipelinesParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _PipelinesController(apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _PipelinesScreen(ctrl, _smartphoneParameters)
          : _PipelinesScreen(ctrl, _tabletParameters),
    );
  }
}
