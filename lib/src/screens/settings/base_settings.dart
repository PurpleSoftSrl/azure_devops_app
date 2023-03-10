library settings;

import 'dart:async';
import 'dart:io';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/alert_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purple_theme/purple_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/link.dart';

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
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _SettingsController(apiService: apiService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _SettingsScreen(ctrl, _smartphoneParameters)
          : _SettingsScreen(ctrl, _tabletParameters),
    );
  }
}
