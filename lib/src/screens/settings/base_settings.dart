library settings;

import 'dart:async';
import 'dart:io';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/mixins/share_mixin.dart';
import 'package:azure_devops/src/models/organization.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/msal_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/utils/utils.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/markdown_widget.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purple_theme/purple_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'components_settings.dart';
part 'controller_settings.dart';
part 'parameters_settings.dart';
part 'screen_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage();

  static const _smartphoneParameters = _SettingsParameters();
  static const _tabletParameters = _SettingsParameters();

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      initState: () => _SettingsController._(context.api, context.storage),
      smartphone: (ctrl) => _SettingsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _SettingsScreen(ctrl, _tabletParameters),
    );
  }
}
