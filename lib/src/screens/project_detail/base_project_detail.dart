library project_detail;

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/api_error_mixin.dart';
import 'package:azure_devops/src/models/board.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/models/project_languages.dart';
import 'package:azure_devops/src/models/repository.dart';
import 'package:azure_devops/src/models/saved_query.dart';
import 'package:azure_devops/src/models/team.dart';
import 'package:azure_devops/src/models/team_member.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:azure_devops/src/widgets/work_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

part 'components_project_detail.dart';
part 'controller_project_detail.dart';
part 'parameters_project_detail.dart';
part 'screen_project_detail.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage();

  static const _smartphoneParameters = _ProjectDetailParameters(gridItemAspectRatio: 1.4, memberAvatarSize: 50);
  static const _tabletParameters = _ProjectDetailParameters(gridItemAspectRatio: 2.4, memberAvatarSize: 75);

  @override
  Widget build(BuildContext context) {
    final project = AppRouter.getProjectDetailArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return AppBasePage(
      initState: () => _ProjectDetailController._(apiService, project),
      smartphone: (ctrl) => _ProjectDetailScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _ProjectDetailScreen(ctrl, _tabletParameters),
    );
  }
}
