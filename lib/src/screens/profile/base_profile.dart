library profile;

import 'dart:async';

import 'package:azure_devops/src/extensions/commit_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/mixins/ads_mixin.dart';
import 'package:azure_devops/src/mixins/filter_mixin.dart';
import 'package:azure_devops/src/models/commit.dart';
import 'package:azure_devops/src/models/user.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/ad_widget.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/commit_list_tile.dart';
import 'package:azure_devops/src/widgets/member_avatar.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_profile.dart';
part 'controller_profile.dart';
part 'parameters_profile.dart';
part 'screen_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage();

  static const _smartphoneParameters = _ProfileParameters();
  static const _tabletParameters = _ProfileParameters();

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      initState: () => _ProfileController._(context.api, context.storage, context.ads),
      smartphone: (ctrl) => _ProfileScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _ProfileScreen(ctrl, _tabletParameters),
    );
  }
}
