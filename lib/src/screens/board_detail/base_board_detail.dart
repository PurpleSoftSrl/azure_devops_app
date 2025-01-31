library board_detail;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/board.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/popup_menu.dart';
import 'package:azure_devops/src/widgets/work_item_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_board_detail.dart';
part 'controller_board_detail.dart';
part 'screen_board_detail.dart';

typedef _BoardDetailParameters = ();

class BoardDetailPage extends StatelessWidget {
  const BoardDetailPage();

  static const _BoardDetailParameters _smartphoneParameters = ();
  static const _BoardDetailParameters _tabletParameters = ();

  @override
  Widget build(BuildContext context) {
    final api = AzureApiServiceInherited.of(context).apiService;
    final args = AppRouter.getBoardDetailArgs(context);
    return AppBasePage(
      initState: () => _BoardDetailController._(api, args),
      smartphone: (ctrl) => _BoardDetailScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _BoardDetailScreen(ctrl, _tabletParameters),
    );
  }
}
