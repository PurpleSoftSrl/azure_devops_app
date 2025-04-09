library notifications_settings;

import 'package:azure_devops/src/extensions/area_or_iteration_extension.dart';
import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/api_error_mixin.dart';
import 'package:azure_devops/src/models/hook_subscriptions.dart';
import 'package:azure_devops/src/models/project.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/notifications_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:azure_devops/src/widgets/app_page.dart';
import 'package:azure_devops/src/widgets/loading_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

part 'components_notifications_settings.dart';
part 'controller_notifications_settings.dart';
part 'screen_notifications_settings.dart';

typedef _NotificationsSettingsParameters = ();

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage();

  static const _NotificationsSettingsParameters _smartphoneParameters = ();
  static const _NotificationsSettingsParameters _tabletParameters = ();

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      initState: () => _NotificationsSettingsController._(context.api, context.storage),
      smartphone: (ctrl) => _NotificationsSettingsScreen(ctrl, _smartphoneParameters),
      tablet: (ctrl) => _NotificationsSettingsScreen(ctrl, _tabletParameters),
    );
  }
}
