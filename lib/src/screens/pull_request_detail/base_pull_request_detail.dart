library pull_request_detail;

import 'dart:async';
import 'dart:convert';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/pull_request_extension.dart';
import 'package:azure_devops/src/mixins/ads_mixin.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/mixins/pull_request_mixin.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/commit.dart' as c;
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/pull_request_policies.dart';
import 'package:azure_devops/src/models/pull_request_with_details.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/add_comment_field.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/changed_files.dart';
import 'package:azure_devops/src/widgets/commit_list_tile.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/markdown_widget.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/pipeline_in_progress_animated_icon.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/project_and_repo_chips.dart';
import 'package:azure_devops/src/widgets/pull_request_comment_card.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    final args = AppRouter.getPullRequestDetailArgs(context);
    return AppBasePage(
      initState: () => _PullRequestDetailController._(args, context.api, context.ads),
      smartphone: (ctrl) => _PullRequestDetailScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _PullRequestDetailScreen(ctrl, _tabletParameters),
    );
  }
}
