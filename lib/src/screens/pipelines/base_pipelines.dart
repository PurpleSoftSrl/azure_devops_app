library pipelines;

import 'dart:async';

import 'package:azure_devops/src/extensions/pipeline_result_extension.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/filters_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/pipeline_list_tile.dart';
import 'package:azure_devops/src/widgets/shortcut_label.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    final storageService = StorageServiceInherited.of(context).storageService;
    final args = AppRouter.getPipelinesArgs(context);
    return AppBasePage(
      initState: () => _PipelinesController._(apiService, storageService, args),
      smartphone: (ctrl) => _PipelinesScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _PipelinesScreen(ctrl, _tabletParameters),
    );
  }
}
