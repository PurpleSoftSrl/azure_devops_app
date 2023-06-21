library repository_detail;

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/repository_branches.dart';
import 'package:azure_devops/src/models/repository_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/filter_menu.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_repository_detail.dart';
part 'controller_repository_detail.dart';
part 'parameters_repository_detail.dart';
part 'screen_repository_detail.dart';

class RepositoryDetailPage extends StatelessWidget {
  const RepositoryDetailPage();

  static const _smartphoneParameters = _RepositoryDetailParameters();
  static const _tabletParameters = _RepositoryDetailParameters();

  @override
  Widget build(BuildContext context) {
    final args = AppRouter.getRepositoryDetailArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _RepositoryDetailController(apiService: apiService, args: args);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _RepositoryDetailScreen(ctrl, _smartphoneParameters)
          : _RepositoryDetailScreen(ctrl, _tabletParameters),
    );
  }
}
