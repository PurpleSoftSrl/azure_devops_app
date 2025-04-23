library commits;

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/ads_mixin.dart';
import 'package:azure_devops/src/mixins/api_error_mixin.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/commits_tags.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/filters_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/ad_widget.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/commit_list_tile.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/shortcut_label.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

part 'components_commits.dart';
part 'controller_commits.dart';
part 'parameters_commits.dart';
part 'screen_commits.dart';

class CommitsPage extends StatelessWidget {
  const CommitsPage();

  static const _smartphoneParameters = _CommitsParameters();
  static const _tabletParameters = _CommitsParameters();

  @override
  Widget build(BuildContext context) {
    final args = AppRouter.getCommitsArgs(context);
    return AppBasePage(
      initState: () => _CommitsController._(context.api, context.storage, args, context.ads),
      smartphone: (ctrl) => _CommitsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _CommitsScreen(ctrl, _tabletParameters),
    );
  }
}
