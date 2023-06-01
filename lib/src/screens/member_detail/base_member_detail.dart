library member_detail;

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/commit_list_tile.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:azure_devops/src/widgets/text_title_description.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

part 'components_member_detail.dart';
part 'controller_member_detail.dart';
part 'parameters_member_detail.dart';
part 'screen_member_detail.dart';

class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage();

  static const _smartphoneParameters = _MemberDetailParameters();
  static const _tabletParameters = _MemberDetailParameters();

  @override
  Widget build(BuildContext context) {
    final member = AppRouter.getMemberDetailArgs(context);
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _MemberDetailController(userDescriptor: member, apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _MemberDetailScreen(ctrl, _smartphoneParameters)
          : _MemberDetailScreen(ctrl, _tabletParameters),
    );
  }
}
