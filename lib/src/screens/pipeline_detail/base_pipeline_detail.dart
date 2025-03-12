library pipeline_detail;

import 'dart:async';
import 'dart:math';

import 'package:azure_devops/src/extensions/approval_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/duration_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_result_extension.dart';
import 'package:azure_devops/src/mixins/ads_mixin.dart';
import 'package:azure_devops/src/mixins/api_error_mixin.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/models/pipeline_approvals.dart';
import 'package:azure_devops/src/models/timeline.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:azure_devops/src/widgets/pipeline_in_progress_animated_icon.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/project_and_repo_chips.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    final args = AppRouter.getPipelineDetailArgs(context);
    return AppBasePage(
      initState: () => _PipelineDetailController._(args, context.api, context.ads),
      smartphone: (ctrl) => _PipelineDetailScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _PipelineDetailScreen(ctrl, _tabletParameters),
    );
  }
}
