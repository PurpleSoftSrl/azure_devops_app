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
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:azure_devops/src/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purple_theme/purple_theme.dart';
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
    final storageService = StorageServiceInherited.of(context).storageService;
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final ctrl = _SettingsController(apiService: apiService, storageService: storageService);
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < AppTheme.tabletBeakpoint
          ? _SettingsScreen(ctrl, _smartphoneParameters)
          : _SettingsScreen(ctrl, _tabletParameters),
    );
  }
}
