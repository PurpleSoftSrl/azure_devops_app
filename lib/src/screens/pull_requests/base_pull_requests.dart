library pull_requests;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/ads_mixin.dart';
import 'package:azure_devops/src/mixins/api_error_mixin.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/filters_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/widgets/ad_widget.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/pull_request_list_tile.dart';
import 'package:azure_devops/src/widgets/search_field.dart';
import 'package:azure_devops/src/widgets/shortcut_label.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

part 'components_pull_requests.dart';
part 'controller_pull_requests.dart';
part 'parameters_pull_requests.dart';
part 'screen_pull_requests.dart';

class PullRequestsPage extends StatelessWidget {
  const PullRequestsPage();

  static const _smartphoneParameters = _PullRequestsParameters();
  static const _tabletParameters = _PullRequestsParameters();

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final storageService = StorageServiceInherited.of(context).storageService;
    final ads = context.adsService;
    final args = AppRouter.getPullRequestsArgs(context);
    return AppBasePage(
      initState: () => _PullRequestsController._(apiService, storageService, args, ads),
      smartphone: (ctrl) => _PullRequestsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _PullRequestsScreen(ctrl, _tabletParameters),
    );
  }
}
