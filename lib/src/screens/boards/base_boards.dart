library boards;

import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/project_card.dart';
import 'package:flutter/material.dart';

part 'components_boards.dart';
part 'controller_boards.dart';
part 'screen_boards.dart';

typedef _BoardsParameters = ({double? projectCardHeight});

class BoardsPage extends StatelessWidget {
  const BoardsPage();

  static const _BoardsParameters _smartphoneParameters = (projectCardHeight: null);
  static const _BoardsParameters _tabletParameters = (projectCardHeight: 60);

  @override
  Widget build(BuildContext context) {
    final api = AzureApiServiceInherited.of(context).apiService;
    return AppBasePage(
      initState: () => _BoardsController._(api),
      smartphone: (ctrl) => _BoardsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _BoardsScreen(ctrl, _tabletParameters),
    );
  }
}
