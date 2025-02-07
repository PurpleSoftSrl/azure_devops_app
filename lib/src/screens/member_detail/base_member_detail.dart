library member_detail;

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
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
    return AppBasePage(
      initState: () => _MemberDetailController._(member, context.api),
      smartphone: (ctrl) => _MemberDetailScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _MemberDetailScreen(ctrl, _tabletParameters),
    );
  }
}
