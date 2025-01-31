library project_boards;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/board.dart';
import 'package:azure_devops/src/models/team.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:flutter/material.dart';

part 'components_project_boards.dart';
part 'controller_project_boards.dart';
part 'screen_project_boards.dart';

typedef _ProjectBoardsParameters = ();

class ProjectBoardsPage extends StatelessWidget {
  const ProjectBoardsPage();

  static const _ProjectBoardsParameters _smartphoneParameters = ();
  static const _ProjectBoardsParameters _tabletParameters = ();

  @override
  Widget build(BuildContext context) {
    final api = AzureApiServiceInherited.of(context).apiService;
    final projectName = AppRouter.getProjectBoardsArgs(context);
    return AppBasePage(
      initState: () => _ProjectBoardsController._(api, projectName),
      smartphone: (ctrl) => _ProjectBoardsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _ProjectBoardsScreen(ctrl, _tabletParameters),
    );
  }
}
